import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/client.dart';
import '../../core/db/app_database.dart';
import '../../modules/auth/services/auth_local.dart';
import 'package:cacao_apps/modules/scan/services/scan_sync_service.dart';

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
      final ok = await _hasInternet();
      if (!ok) return;

      await _scanSync.syncPendingScans();
    } finally {
      _running = false;
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final res = await DioClient.dio.get('/api/health');
      return res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }
}
