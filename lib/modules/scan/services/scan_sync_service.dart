import 'dart:developer' as developer; // Added for structured logging
import 'package:dio/dio.dart';

// 1. Import your new repositories
import 'package:cacao_apps/core/db/scan_repository.dart';
import 'package:cacao_apps/core/db/user_repository.dart';

class ScanSyncService {
  final Dio dio;
  
  // 2. Define the new repository dependencies
  final ScanRepository scanRepository;
  final UserRepository _userRepository = UserRepository();

  // 3. Update constructor to accept scanRepository (fixes your SyncTrigger error!)
  ScanSyncService({required this.dio, required this.scanRepository});

  Future<void> syncPendingScans() async {
    developer.log('Batch Sync started...', name: 'ScanSync');

    // 4. Use the UserRepository to get the current user
    final currentUser = await _userRepository.getCurrentUser();
    if (currentUser == null) {
      developer.log('No user found. Aborting sync.', name: 'ScanSync');
      return;
    }

    // 5. Use ScanRepository for all scan-related queries
    final pending = await scanRepository.getPendingScans(
      userId: currentUser.userId,
      limit: 50,
    );

    if (pending.isEmpty) {
      developer.log('No pending scans.', name: 'ScanSync');
      return;
    }

    developer.log(
      'Preparing ${pending.length} scans for batch upload...',
      name: 'ScanSync',
    );

    final scansPayload = pending.map((row) {
      return {
        'local_id': (row['local_id'] ?? '').toString(),
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
        'idempotency_key': (row['idempotency_key'] ?? row['local_id'])
            .toString(),
      };
    }).toList();

    try {
      developer.log('Sending batch request...', name: 'ScanSync');

      final res = await dio.post(
        '/api/theobrotect/scans/sync',
        data: {'scans': scansPayload},
      );

      if (res.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final data = res.data;

      if (res.statusCode != 200 || data['status'] != 'OK') {
        developer.log('Batch sync failed', name: 'ScanSync');
        return;
      }

      final results = data['results'] as List<dynamic>;

      for (final result in results) {
        final localId = result['local_id'];

        if (result['status'] == 'OK') {
          final scan = result['data'];
          final backendId = (scan['id'] ?? scan['_id'] ?? localId).toString();

          // 6. Update successful sync via repository
          await scanRepository.markScanSynced(localId: localId, backendId: backendId);

          developer.log('Synced $localId', name: 'ScanSync');
        } else if (result['status'] == 'skipped') {
          developer.log(
            'Skipped $localId (already exists)',
            name: 'ScanSync',
          );
        } else {
          // 7. Update failed sync via repository
          await scanRepository.markScanSyncFailed(
            localId: localId,
            errorMessage: result['message'] ?? 'Batch error',
          );

          developer.log('❌ Failed $localId', name: 'ScanSync');
        }
      }
    } on DioException catch (e) {
      developer.log('🌐 Network/API error: ${e.message}', name: 'ScanSync');
    } catch (e) {
      developer.log('🚨 Unexpected error: $e', name: 'ScanSync');
    }

    developer.log('🏁 Batch sync finished.', name: 'ScanSync');
  }
}