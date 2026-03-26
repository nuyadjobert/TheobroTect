import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/client.dart';
import '../../core/db/app_database.dart';
import 'package:cacao_apps/modules/scan/services/scan_sync_service.dart';

class SyncTrigger {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _retryTimer;
  bool _running = false;

  late final ScanSyncService _scanSync;

  SyncTrigger() {
    _scanSync = ScanSyncService(
      dio: DioClient.dio,
      db: AppDatabase(),
    );
  }

  Future<void> start() async {
    // don't await — let it run in the background so it won't block the UI
    _trySync();

    // listen for connectivity changes
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        _trySync();
      }
    });

    // periodic retry every 5 minutes for scans that failed earlier
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _trySync();
    });
  }

  Future<void> stop() async {
    _retryTimer?.cancel();
    _retryTimer = null;
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
      final res = await DioClient.dio.get('/api/theobrotect/test');
      return res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }
}