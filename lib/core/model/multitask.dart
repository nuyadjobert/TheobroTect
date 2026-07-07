class MultiTaskPrediction {
  final String diseaseLabel;
  final String severityLabel;
  final double diseaseConfidence;
  final double severityConfidence;

  MultiTaskPrediction({
    required this.diseaseLabel,
    required this.severityLabel,
    required this.diseaseConfidence,
    required this.severityConfidence,
  });
}