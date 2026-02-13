class ScanResultModel {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? imagePath;

  const ScanResultModel({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.imagePath,
  });
}
