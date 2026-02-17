import 'package:cacao_apps/core/db/app_database.dart';
import 'package:cacao_apps/modules/auth/services/auth_local.dart';
import 'package:dio/dio.dart';

class ScanSyncService {
  final Dio dio;
  final AppDatabase db;
  final AuthSecureStore secureStore;

  ScanSyncService({
    required this.dio,
    required this.db,
    required this.secureStore,
  });

  Future<void> syncPendingScans() async {
    final token = await secureStore.readToken();
    if (token == null || token.isEmpty) return;

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
        'scanned_at': row['scanned_at'],
        'next_scan_at': row['next_scan_at'],
      };

      try {
        final res = await dio.post(
          '/api/scans/sync',
          data: payload,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        final data = res.data as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final scan = data['scan'] as Map<String, dynamic>?;
          final backendId = (scan?['id'] ?? scan?['_id'] ?? '').toString();

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
      } catch (e) {
        await db.markScanSyncFailed(
          localId: localId,
          errorMessage: e.toString(),
        );
      }
    }
  }
}
