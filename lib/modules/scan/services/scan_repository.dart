import 'package:uuid/uuid.dart';
import '../../../core/db/app_database.dart';

class ScanRepository {
  final _dbProvider = AppDatabase();
  final _uuid = const Uuid();

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
    return localId;
  }
}
