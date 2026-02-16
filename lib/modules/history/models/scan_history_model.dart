class ScanHistory {
  final int id;
  final String diseaseKey;
  final String createdAt;
  final double confidence;
  final String severityKey;
  final String? imagePath;

  ScanHistory({
    required this.id,
    required this.diseaseKey,
    required this.createdAt,
    required this.confidence,
    required this.severityKey,
    this.imagePath,
  });

  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'] as int,
      diseaseKey: map['disease_key'] as String,
      createdAt: map['created_at'] as String,
      confidence: map['confidence'] as double,
      severityKey: map['severity_key'] as String,
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, dynamic> toFormattedMap() {
    return {
      "title": diseaseKey.replaceAll('_', ' ').toUpperCase(),
      "date": createdAt,
      "confidence": (confidence * 100).toStringAsFixed(1),
      "status": severityKey == 'default' ? 'Healthy' : 'Infected',
      "image": imagePath,
      "isLocalFile": true,
    };
  }
}