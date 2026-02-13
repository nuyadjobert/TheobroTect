import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../core/db/app_database.dart';
import '../../auth/services/auth_local.dart';
import '../../../core/network/client.dart';

class ScanRepository {
  final _dbProvider = AppDatabase();
  final _uuid = const Uuid();
  final _connectivity = Connectivity();

  Future<String> insertScan({
    required String userId,
    required String deviceId,
    required String modelLabel,
    required String diseaseKey,
    required String severityKey,
    required double confidence,
    String? imagePath,
    DateTime? nextScanAt,
    int? notifLocalId,
    bool smsEnabled = false,
  }) async {
    final db = await _dbProvider.db;
    final localId = _uuid.v4();
    final nowIso = DateTime.now().toIso8601String();

    // 1) Always save locally first
    await db.insert('scan_history', {
      'local_id': localId,
      'user_id': userId,
      'device_id': deviceId,
      'created_at': nowIso,
      'image_path': imagePath,
      'model_label': modelLabel,
      'disease_key': diseaseKey,
      'severity_key': severityKey,
      'confidence': confidence,
      'next_scan_at': nextScanAt?.toIso8601String(),
      'notif_local_id': notifLocalId,
      'sms_enabled': smsEnabled ? 1 : 0,
      'sync_state': 'pending',
      'sync_attempts': 0,
    });

    // Payload for backend (do NOT send local image path)
    final payload = {
      'local_id': localId,
      'device_id': deviceId,
      'created_at_client': nowIso,
      'model_label': modelLabel,
      'disease_key': diseaseKey,
      'severity_key': severityKey,
      'confidence': confidence,
      'next_scan_at_client': nextScanAt?.toIso8601String(),
    };

    // 2) If online, try immediate sync
    final conn = await _connectivity.checkConnectivity();
    final isOnline = conn != ConnectivityResult.none;

    if (isOnline) {
      final synced = await _tryUploadNow(userId: userId, localId: localId, payload: payload);
      if (synced) return localId;
    }

    // 3) If offline OR upload failed → queue in outbox
    await _enqueueOutbox(userId: userId, payload: payload, createdAtIso: nowIso);

    return localId;
  }

  Future<bool> _tryUploadNow({
    required String userId,
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _dbProvider.db;

    try {
      final token = await AuthSecureStore().readToken();
      if (token == null) throw Exception('Missing auth token');

      DioClient.dio.options.headers['Authorization'] = 'Bearer $token';

      // Backend route example:
      // POST /api/scans  -> returns { backend_id: "..." }
      final res = await DioClient.dio.post('/api/scans', data: payload);
      final backendId = res.data['backend_id'] as String?;

      await db.update(
        'scan_history',
        {
          'sync_state': 'synced',
          'backend_id': backendId,
          'last_sync_at': DateTime.now().toIso8601String(),
        },
        where: 'local_id = ?',
        whereArgs: [localId],
      );

      return true;
    } catch (e) {
      // mark attempt (optional)
      await db.rawUpdate(
        'UPDATE scan_history SET sync_attempts = sync_attempts + 1 WHERE local_id = ?',
        [localId],
      );
      return false;
    }
  }

  Future<void> _enqueueOutbox({
    required String userId,
    required Map<String, dynamic> payload,
    required String createdAtIso,
  }) async {
    final db = await _dbProvider.db;

    await db.insert('outbox', {
      'user_id': userId,
      'type': 'scan_upsert',
      'payload_json': jsonEncode(payload),
      'status': 'pending',
      'attempts': 0,
      'created_at': createdAtIso,
    });
  }

  Future<List<Map<String, Object?>>> getHistory(String userId) async {
    final db = await _dbProvider.db;
    return db.query(
      'scan_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }
}
