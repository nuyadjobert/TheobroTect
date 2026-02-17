import 'dart:async';
import 'package:cacao_apps/modules/scan/services/scan_sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/client.dart';
import '../../core/db/app_database.dart';
import '../../modules/auth/services/auth_local.dart';

class SyncTrigger {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _running = false;

  late final ScanSyncService _scanSync;

  SyncTrigger() {
    _scanSync = ScanSyncService(
      dio: DioClient.dio,
      db: AppDatabase(),
      secureStore: AuthSecureStore(),
    );
  }

  Future<void> start() async {
    // Try once at startup (in case already online)
    await _trySync();

    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        await _trySync();
      }
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _trySync() async {
    if (_running) return;
    _running = true;
    try {
      await _scanSync.syncPendingScans();
    } finally {
      _running = false;
    }
  }
}
