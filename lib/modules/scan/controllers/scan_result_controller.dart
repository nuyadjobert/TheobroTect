import 'package:cacao_apps/core/guide/cacao_guide_service.dart';
import 'package:flutter/material.dart';

class ScanResultController extends ChangeNotifier {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? imagePath;
  final CacaoGuideService _guide = CacaoGuideService();

  ScanResultController({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.imagePath,
  });
    late final String diseaseKey;
  late final String severityKey;

  // UI state
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Display fields (from JSON)
  Map<String, String> displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
  Map<String, String> description = const {"en": "", "tl": ""};

  // Recommendation fields (from JSON)
  List<String> whatToDoNowEn = const [];
  List<String> whatToDoNowTl = const [];

  List<String> preventionEn = const [];
  List<String> preventionTl = const [];

  List<String> whenToEscalateEn = const [];
  List<String> whenToEscalateTl = const [];

  // Optional monitoring plan
  int? rescanAfterDays;
  Map<String, String>? rescanMessage; // {"en": "...", "tl": "..."}

  List<TreatmentTask> get treatmentPlan {
    // You can later switch logic using diseaseName/severity
    if (diseaseName.toLowerCase().contains('black pod')) {
      return const [
        TreatmentTask(
          icon: Icons.delete_outline_rounded,
          title: "Remove & Bury",
          desc: "Dig a deep pit and bury infected pods to stop the spread.",
        ),
        TreatmentTask(
          icon: Icons.science_outlined,
          title: "Apply Fungicide",
          desc: "Use copper-based spray on surrounding pods if advised by your local agriculturist.",
        ),
        TreatmentTask(
          icon: Icons.sanitizer_outlined,
          title: "Sterilize Tools",
          desc: "Clean pruning shears after every cut to prevent spreading.",
        ),
      ];
    }

    // Default fallback
    return const [
      TreatmentTask(
        icon: Icons.visibility_outlined,
        title: "Monitor",
        desc: "Observe the pod and rescan after a few days.",
      ),
      TreatmentTask(
        icon: Icons.cleaning_services_outlined,
        title: "Sanitation",
        desc: "Remove debris and keep the area clean to reduce spread.",
      ),
    ];
  }

  bool _isBookmarked = false;
  bool get isBookmarked => _isBookmarked;

  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
    notifyListeners();
  }
}

class TreatmentTask {
  final IconData icon;
  final String title;
  final String desc;

  const TreatmentTask({
    required this.icon,
    required this.title,
    required this.desc,
  });
}
