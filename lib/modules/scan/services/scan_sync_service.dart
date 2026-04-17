import 'dart:developer' as developer; // Added for structured logging
import 'package:cacao_apps/core/db/app_database.dart';
import 'package:dio/dio.dart';

class ScanSyncService {
  final Dio dio;
  final AppDatabase db;

  ScanSyncService({required this.dio, required this.db});

  Future<void> syncPendingScans() async {
    developer.log(
      '🔄 Initialization: Checking for pending scans...',
      name: 'ScanSync',
    );

    final currentUser = await db.getCurrentUser();
    if (currentUser == null) {
      developer.log(
        '⚠️ Sync aborted: No current user found.',
        name: 'ScanSync',
      );
      return;
    }

    final pending = await db.getPendingScans(
      userId: currentUser.userId,
      limit: 50,
    );

    if (pending.isEmpty) {
      developer.log(
        '✅ Sync complete: No pending scans to upload.',
        name: 'ScanSync',
      );
      return;
    }

    developer.log(
      '🚀 Found ${pending.length} pending scans. Starting upload...',
      name: 'ScanSync',
    );

    for (final row in pending) {
      final localId = (row['local_id'] ?? '').toString();
      if (localId.isEmpty) continue;

      final payload = {
        'local_id': localId,
        'disease_key': row['disease_key'],
        'severity_key': row['severity_key'],
        'confidence': row['confidence'],

        'location_lat': row['location_lat'] ?? 0,
        'location_lng': row['location_lng'] ?? 0,
        'location_accuracy': row['location_accuracy'],
        'location_label': row['location_label'],

        'scanned_at': row['scanned_at'],
        'next_scan_at': row['next_scan_at'],
        'Status': row['Status'] ?? 1,
      };

      try {
        final idempotencyKey = (row['idempotency_key'] ?? row['local_id'])
            .toString();

        developer.log(
          '📤 Uploading Scan [LocalID: $localId]...',
          name: 'ScanSync',
        );

        final res = await dio.post(
          '/api/theobrotect/scans/scan-results',
          data: payload,
          options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        );

        final data = res.data as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final scan = data['data'] as Map<String, dynamic>?;
          final backendId = (scan?['id'] ?? scan?['_id'] ?? '').toString();

          await db.markScanSynced(
            localId: localId,
            backendId: backendId.isEmpty ? localId : backendId,
          );

          developer.log(
            '✨ Success: Scan $localId synced. BackendID: $backendId',
            name: 'ScanSync',
          );
        } else {
          final error = 'Backend status: ${data['status']}';
          await db.markScanSyncFailed(localId: localId, errorMessage: error);
          developer.log(
            '❌ Failed: Server returned status ${data['status']} for Scan $localId',
            name: 'ScanSync',
            error: error,
          );
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          developer.log(
            '📶 Sync paused: Connection error/timeout. Will retry later.',
            name: 'ScanSync',
          );
          return;
        }

        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );
        developer.log(
          '❌ Dio Error: Could not sync Scan $localId',
          name: 'ScanSync',
          error: e.message,
        );
      } catch (e) {
        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );
        developer.log(
          '🚨 Unexpected Error: Scan $localId',
          name: 'ScanSync',
          error: e.toString(),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    developer.log('🏁 Finished processing pending queue.', name: 'ScanSync');
  }
}
