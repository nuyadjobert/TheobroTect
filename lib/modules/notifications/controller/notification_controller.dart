import 'package:flutter/material.dart';
import '../../../core/db/scan_repository.dart';

class NotificationController extends ChangeNotifier {
  final ScanRepository repository;

  NotificationController(this.repository);

 final List<Map<String, dynamic>> _alerts = [];

  void ignoreAlert(int index) {
    if (index >= 0 && index < _alerts.length) {
      _alerts.removeAt(index);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get alerts =>
    List.unmodifiable(_alerts);

  void addAlert({
    required String disease,
    required String severity,
    required String date,
    required String sector,
  }) {
    _alerts.insert(0, {
      "disease": disease,
      "severity": severity,
      "date": date,
      "sector": sector,
    });

    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  Future<void> loadNotifications(String userId) async {
    final rows = await repository.getPendingNotifications(userId);

    final now = DateTime.now();

    _alerts.clear();

    for (final row in rows) {
      final nextScan = DateTime.parse(row['next_scan_at']);

      if (!nextScan.isAfter(now)) {
        // Show in the NotificationScreen
        _alerts.add({
          "local_id": row["local_id"] as String,
          "disease": row["disease_key"] as String,
          "severity": row["severity_key"] as String,
          "date": row["scanned_at"] as String,
          "sector": row["location_label"]?.toString() ?? "",
        });
      }
    }

    notifyListeners();
  }

  Future<void> dismissAlert(int index) async {
    final localId = _alerts[index]["local_id"]!;

    await repository.markNotificationShown(localId);

    _alerts.removeAt(index);

    notifyListeners();
  }

  Future<void> rescanAlert(int index) async {
    final localId = _alerts[index]["local_id"]!;

    await repository.markNotificationShown(localId);

    _alerts.removeAt(index);

    notifyListeners();
  }
}
