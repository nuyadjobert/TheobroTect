import 'package:cacao_apps/core/db/app_database.dart';
import 'package:dio/dio.dart';

class ScanSyncService {
  final Dio dio;
  final AppDatabase db;

  ScanSyncService({required this.dio, required this.db});

  Future<void> syncPendingScans() async {
    final pending = await db.getPendingScans(limit: 50);
    if (pending.isEmpty) return;

    for (final row in pending) {
      final localId = (row['local_id'] ?? '').toString();
      if (localId.isEmpty) continue;

      final payload = {
        'local_id': row['local_id'],
        'disease_key': row['disease_key'],
        'severity_key': row['severity_key'],
        'confidence': row['confidence'],
        'location_lat': row['location_lat'],
        'location_lng': row['location_lng'],
        'location_accuracy': row['location_accuracy'],
        'location_label': row['location_label'],
        'scanned_at': row['scanned_at'],
        'next_scan_at': row['next_scan_at'],
      };

      try {
        final idempotencyKey =
            (row['idempotency_key'] ?? row['local_id']).toString();

        final res = await dio.post(
          '/api/theobrotect/scans/scan-results',
          data: payload,
          options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        );

        final data = res.data as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final scan = data['data'] as Map<String, dynamic>?;
          final backendId =
              (scan?['id'] ?? scan?['_id'] ?? '').toString();

          await db.markScanSynced(
            localId: localId,
            backendId: backendId.isEmpty ? localId : backendId,
          );
        } else {
          await db.markScanSyncFailed(
            localId: localId,
            errorMessage: 'Backend status: ${data['status']}',
          );
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          return; 
        }

        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );
      } catch (e) {
        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}