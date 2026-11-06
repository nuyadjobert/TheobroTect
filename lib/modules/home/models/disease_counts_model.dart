class DiseaseCountsModel {
  final int healthy;
  final int blackPodDisease;
  final int cacaoPodBorer;
  final int mealybug;

  DiseaseCountsModel({
    required this.healthy,
    required this.blackPodDisease,
    required this.cacaoPodBorer,
    required this.mealybug,
  });

  int get totalScans => healthy + blackPodDisease + cacaoPodBorer + mealybug;

  int get totalDiseased => blackPodDisease + cacaoPodBorer + mealybug;

  factory DiseaseCountsModel.fromJson(Map<String, dynamic> json) {
    return DiseaseCountsModel(
      healthy: (json['healthy'] ?? 0) as int,
      blackPodDisease: (json['black_pod_disease'] ?? 0) as int,
      cacaoPodBorer: (json['cacao_pod_borer'] ?? 0) as int,
      mealybug: (json['mealybug'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthy': healthy,
      'black_pod_disease': blackPodDisease,
      'cacao_pod_borer': cacaoPodBorer,
      'mealybug': mealybug,
    };
  }

  factory DiseaseCountsModel.empty() {
    return DiseaseCountsModel(
      healthy: 0,
      blackPodDisease: 0,
      cacaoPodBorer: 0,
      mealybug: 0,
    );
  }

  bool get isEmpty => totalScans == 0;
}
