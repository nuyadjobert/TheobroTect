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
        email TEXT,
        name TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    await database.execute('''
     CREATE TABLE IF NOT EXISTS scan_history (
 
          local_id TEXT PRIMARY KEY,            

          user_id TEXT NOT NULL,

          scanned_at TEXT NOT NULL,             
          image_path TEXT,                      
          disease_key TEXT NOT NULL,            
          severity_key TEXT NOT NULL,           
          confidence REAL NOT NULL,             

          location_lat REAL,
          location_lng REAL,
          location_accuracy REAL,
          location_label TEXT,  

          next_scan_at TEXT,                     
          notif_local_id INTEGER,                
          sms_enabled INTEGER DEFAULT 0,         


          sync_state TEXT DEFAULT 'pending',    
          backend_id TEXT,                       
          sync_attempts INTEGER DEFAULT 0,
          last_sync_at TEXT,

          created_at TEXT NOT NULL,              
          updated_at TEXT,                      

  FOREIGN KEY (user_id) REFERENCES users(user_id)
); ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_scan_user ON scan_history(user_id);',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_outbox_status ON outbox(status);',
    );
  }
}
