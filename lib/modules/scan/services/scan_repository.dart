import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/db/app_database.dart';

class ScanRepository {
  final AppDatabase _dbProvider;
  final Uuid _uuid;

  ScanRepository({AppDatabase? dbProvider, Uuid? uuid})
    : _dbProvider = dbProvider ?? AppDatabase(),
      _uuid = uuid ?? const Uuid();

  Future<String> insertScan({
    required String userId,
    required String diseaseKey,
    required String severityKey,
    required double confidence,
    String? imagePath,

    // optional extras
    String? idempotencyKey,
    DateTime? scannedAt,
    DateTime? createdAt,
    DateTime? nextScanAt,

    // location
    double? locationLat,
    double? locationLng,
    double? locationAccuracy,
    String? locationLabel,

    // notification + SMS
    int? notifLocalId,
    bool smsEnabled = false,

    // sync tracking
    String syncState = 'pending',
    String? backendId,
    int syncAttempts = 0,
    DateTime? lastSyncAt,
    String? lastError,
    DateTime? nextRetryAt,
    DateTime? updatedAt,

    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await _dbProvider.db;

    final localId = _uuid.v4();
    final now = DateTime.now();

    final scanned = scannedAt ?? now;
    final created = createdAt ?? now;
    final idemKey = idempotencyKey ?? _uuid.v4();

    await db.insert('scan_history', {
      'local_id': localId,
      'idempotency_key': idemKey,

      'user_id': userId,
      'scanned_at': scanned.toIso8601String(),
      'created_at': created.toIso8601String(),

      'image_path': imagePath,
      'disease_key': diseaseKey,
      'severity_key': severityKey,
      'confidence': confidence,

      'location_lat': locationLat,
      'location_lng': locationLng,
      'location_accuracy': locationAccuracy,
      'location_label': locationLabel,

      'next_scan_at': nextScanAt?.toIso8601String(),
      'notif_local_id': notifLocalId,
      'sms_enabled': smsEnabled ? 1 : 0,

      'sync_state': syncState,
      'backend_id': backendId,
      'sync_attempts': syncAttempts,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'last_error': lastError,
      'next_retry_at': nextRetryAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    }, conflictAlgorithm: conflictAlgorithm);

    return localId;
  }

  Future<Map<String, Object?>?> getScanByLocalId(String localId) async {
    final db = await _dbProvider.db;
    final rows = await db.query(
      'scan_history',
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
