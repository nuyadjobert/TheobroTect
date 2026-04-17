import 'dart:developer' as developer; // Added for structured logging
import 'package:cacao_apps/core/db/app_database.dart';
import 'package:dio/dio.dart';

class ScanSyncService {
  final Dio dio;
  final AppDatabase db;

  ScanSyncService({required this.dio, required this.db});

  Future<void> syncPendingScans() async {
    developer.log('🔄 Sync started...', name: 'ScanSync');

    final currentUser = await db.getCurrentUser();
    if (currentUser == null) {
      developer.log('❌ No user found. Aborting sync.', name: 'ScanSync');
      return;
    }

    final pending = await db.getPendingScans(
      userId: currentUser.userId,
      limit: 50,
    );

    if (pending.isEmpty) {
      developer.log('✅ No pending scans.', name: 'ScanSync');
      return;
    }

    developer.log(
      '📦 Found ${pending.length} pending scans.',
      name: 'ScanSync',
    );

    for (final row in pending) {
      final localId = (row['local_id'] ?? '').toString();
      if (localId.isEmpty) continue;

      final payload = {
        'local_id': localId,
        'disease_key': row['disease_key'],
        'image_url': row['image_url'],
        'severity_key': row['severity_key'],
        'confidence': row['confidence'],
        'location_lat': row['location_lat'] ?? 0,
        'location_lng': row['location_lng'] ?? 0,
        'location_accuracy': row['location_accuracy'],
        'location_label': row['location_label'],
        'scanned_at': row['scanned_at'],
        'next_scan_at': row['next_scan_at'],
        'status': row['status'] ?? 1,
      };

      try {
        final idempotencyKey = (row['idempotency_key'] ?? row['local_id'])
            .toString();

        developer.log('⬆️ Uploading $localId...', name: 'ScanSync');

        final res = await dio.post(
          '/api/theobrotect/scans/sync',
          data: payload,
          options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        );

        // ✅ Check response type
        if (res.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format (not JSON)');
        }

        final data = res.data;

        // ✅ Handle HTTP status
        if (res.statusCode != 200) {
          final msg = data['message'] ?? 'HTTP ${res.statusCode} error';

          await db.markScanSyncFailed(localId: localId, errorMessage: msg);

          developer.log('❌ HTTP Error ($localId): $msg', name: 'ScanSync');
          continue;
        }

        // ✅ Handle backend response
        if (data['status'] != 'OK') {
          final msg = data['message'] ?? 'Unknown backend error';

          await db.markScanSyncFailed(localId: localId, errorMessage: msg);

          developer.log('❌ Backend Error ($localId): $msg', name: 'ScanSync');
          continue;
        }

        final scan = data['data'] as Map<String, dynamic>?;
        final backendId = (scan?['id'] ?? scan?['_id'] ?? localId).toString();

        await db.markScanSynced(localId: localId, backendId: backendId);

        developer.log('✅ Synced $localId → $backendId', name: 'ScanSync');
      } on DioException catch (e) {
        final status = e.response?.statusCode;

        // 🔐 AUTH ERROR
        if (status == 401) {
          developer.log(
            '🔐 Unauthorized. Token invalid. Stopping sync.',
            name: 'ScanSync',
          );
          return;
        }

        // 🌐 NETWORK ERROR
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          developer.log('🌐 Network issue. Sync paused.', name: 'ScanSync');
          break;
        }

        // ❌ OTHER ERRORS
        final msg = e.response?.data?.toString() ?? e.message;

        await db.markScanSyncFailed(localId: localId, errorMessage: msg ?? 'Unknown error');

        developer.log('❌ Dio Error ($localId): $msg', name: 'ScanSync');
      } catch (e) {
        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );

        developer.log('🚨 Unexpected Error ($localId): $e', name: 'ScanSync');
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    developer.log('🏁 Sync finished.', name: 'ScanSync');
  }
}
