
class ModelPrediction {
  final String label;
  final double confidence;
  final int index;

  ModelPrediction({
    required this.label,
    required this.confidence,
    required this.index,
  });

  bool get isNonCacao => label == "non_cacao";
}