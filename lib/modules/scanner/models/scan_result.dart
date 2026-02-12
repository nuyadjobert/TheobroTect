class ScanResult {
  final String rawLabel;       
  final String diseaseKey;    
  final String severityKey;   
  final double confidence;      
  final List<Map<String, double>> topK; 

  const ScanResult({
    required this.rawLabel,
    required this.diseaseKey,
    required this.severityKey,
    required this.confidence,
    required this.topK,
  });

  bool get isUncertain => diseaseKey == "unknown" || confidence < 0.60;
}
