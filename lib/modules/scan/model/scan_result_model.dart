class ScanResultModel {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? imagePath;

  final String? secondaryDiseaseName;
  final double? secondaryConfidence;
  final String? secondarySeverity;

  ScanResultModel({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.imagePath,

    this.secondaryDiseaseName,
    this.secondaryConfidence,
    this.secondarySeverity,
  });
}