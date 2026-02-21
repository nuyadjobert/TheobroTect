import 'package:cacao_apps/core/model/user.model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cacao_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        await _createTables(database);
      },
    );
  }

  Future<void> _createTables(Database database) async {
    await database.execute('''
    CREATE TABLE IF NOT EXISTS users (
      user_id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  ''');

    await database.execute('''
    CREATE TABLE IF NOT EXISTS scan_history (

      -- Identity
      local_id TEXT PRIMARY KEY,                 
      backend_id TEXT,                           

      -- Ownership
      user_id TEXT NOT NULL,

      -- Scan Data
      scanned_at TEXT NOT NULL,
      image_path TEXT,
      disease_key TEXT NOT NULL,
      severity_key TEXT NOT NULL,
      confidence REAL NOT NULL,

      -- Location
      location_lat REAL,
      location_lng REAL,
      location_accuracy REAL,
      location_label TEXT,

      -- Follow-up
      next_scan_at TEXT,
      notif_local_id INTEGER,
      sms_enabled INTEGER DEFAULT 0,

      -- Sync State Machine
      sync_state TEXT NOT NULL DEFAULT 'pending',   -- pending | error | synced
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_sync_at TEXT,
      last_error TEXT,

      -- Retry + Idempotency
      next_retry_at TEXT,
      idempotency_key TEXT NOT NULL,

      -- Audit
      created_at TEXT NOT NULL,
      updated_at TEXT,

      FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
  ''');

    await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_scan_user
    ON scan_history(user_id);
  ''');

    await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_scan_sync
    ON scan_history(sync_state, next_retry_at);
  ''');

    await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_scan_scanned_at
    ON scan_history(scanned_at);
  ''');

    await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_scan_backend
    ON scan_history(backend_id);
  ''');

    await database.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_scan_idempotency_key
    ON scan_history(idempotency_key);
  ''');
  }

  Future<void> upsertUser(LocalUser user) async {
    final database = await db;
    await database.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LocalUser?> getCurrentUser() async {
    final database = await db;
    final rows = await database.query('users', limit: 1);
    if (rows.isEmpty) return null;
    return LocalUser.fromMap(rows.first);
  }

  Future<void> clearUsers() async {
    final database = await db;
    await database.delete('users');
  }

  Future<List<Map<String, Object?>>> getPendingScans({int limit = 20}) async {
    final database = await db;
    return database.query(
      'scan_history',
      where: "sync_state IN ('pending','error')",
      orderBy: 'scanned_at ASC',
      limit: limit,
    );
  }

  Future<void> markScanSynced({
    required String localId,
    required String backendId,
  }) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    await database.update(
      'scan_history',
      {
        'sync_state': 'synced',
        'backend_id': backendId,
        'last_sync_at': now,
        'updated_at': now,
        'sync_attempts': 0,
        'last_error': null,
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markScanSyncFailed({
    required String localId,
    required String errorMessage,
  }) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    await database.rawUpdate(
      '''
    UPDATE scan_history
    SET sync_state = 'error',
        sync_attempts = COALESCE(sync_attempts, 0) + 1,
        last_sync_at = ?,
        updated_at = ?
    WHERE local_id = ?
  ''',
      [now, now, localId],
    );
  }
}
