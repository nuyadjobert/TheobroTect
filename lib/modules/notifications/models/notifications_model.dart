class NotificationModel {
  final String localId;
  final String diseaseKey;
  final String severityKey;
  final DateTime scannedAt;
  final DateTime nextScanAt;

  NotificationModel({
    required this.localId,
    required this.diseaseKey,
    required this.severityKey,
    required this.scannedAt,
    required this.nextScanAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      localId: map['local_id'],
      diseaseKey: map['disease_key'],
      severityKey: map['severity_key'],
      scannedAt: DateTime.parse(map['scanned_at']),
      nextScanAt: DateTime.parse(map['next_scan_at']),
    );
  }
}