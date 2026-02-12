class CacaoGuide {
  final List<String> labelsInOrder;
  final double uncertainThreshold;
  final Map<String, DiseaseGuide> diseases;

  const CacaoGuide({
    required this.labelsInOrder,
    required this.uncertainThreshold,
    required this.diseases,
  });

  factory CacaoGuide.fromJson(Map<String, dynamic> json) {
    final model = json["model"] as Map<String, dynamic>;
    final labels = (model["labels_in_order"] as List).cast<String>();
    final conf = model["confidence"] as Map<String, dynamic>;
    final threshold = (conf["uncertain_threshold"] as num).toDouble();

    final diseasesJson = json["diseases"] as Map<String, dynamic>;
    final diseases = <String, DiseaseGuide>{};
    diseasesJson.forEach((key, val) {
      diseases[key] = DiseaseGuide.fromJson(key, val as Map<String, dynamic>);
    });

    return CacaoGuide(
      labelsInOrder: labels,
      uncertainThreshold: threshold,
      diseases: diseases,
    );
  }

  DiseaseGuide? disease(String key) => diseases[key];
}

class DiseaseGuide {
  final String key;
  final Map<String, String> displayName; // {en:..., tl:...}
  final Map<String, String> description; // {en:..., tl:...}
  final Map<String, Recommendation> recommendationsBySeverity; // mild/moderate/severe/default

  const DiseaseGuide({
    required this.key,
    required this.displayName,
    required this.description,
    required this.recommendationsBySeverity,
  });

  factory DiseaseGuide.fromJson(String key, Map<String, dynamic> json) {
    final recs = <String, Recommendation>{};
    final recJson = json["recommendations"] as Map<String, dynamic>;
    recJson.forEach((sev, data) {
      recs[sev] = Recommendation.fromJson(data as Map<String, dynamic>);
    });

    return DiseaseGuide(
      key: key,
      displayName: (json["display_name"] as Map).cast<String, String>(),
      description: (json["description"] as Map).cast<String, String>(),
      recommendationsBySeverity: recs,
    );
  }

  Recommendation? recommendationFor(String severityKey) {
    return recommendationsBySeverity[severityKey] ?? recommendationsBySeverity["default"];
  }
}

class Recommendation {
  final Map<String, List<String>> whatToDoNow;     // {en:[..], tl:[..]}
  final Map<String, List<String>> prevention;      // {en:[..], tl:[..]}
  final Map<String, List<String>> whenToEscalate;  // optional
  final Map<String, List<String>> monitoring;      // optional
  final Map<String, List<String>> seekHelp;        // optional

  const Recommendation({
    required this.whatToDoNow,
    required this.prevention,
    required this.whenToEscalate,
    required this.monitoring,
    required this.seekHelp,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> _langList(String key) {
      final v = json[key];
      if (v == null) return {"en": const [], "tl": const []};
      final m = (v as Map).cast<String, dynamic>();
      return {
        "en": (m["en"] as List?)?.cast<String>() ?? const [],
        "tl": (m["tl"] as List?)?.cast<String>() ?? const [],
      };
    }

    return Recommendation(
      whatToDoNow: _langList("what_to_do_now"),
      prevention: _langList("prevention"),
      whenToEscalate: _langList("when_to_escalate"),
      monitoring: _langList("monitoring"),
      seekHelp: _langList("seek_help"),
    );
  }
}
