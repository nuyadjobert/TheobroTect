import 'package:cacao_apps/core/guide/cacao_guide_service.dart';
import 'package:flutter/material.dart';

class ScanResultController extends ChangeNotifier {
  final String diseaseName;   // from scanner UI
  final double confidence;
  final String severity;      // "Mild/Moderate/Severe"
  final String? imagePath;

  final CacaoGuideService _guide = CacaoGuideService();

  ScanResultController({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.imagePath,
  });

  // -------------------------
  // UI state
  // -------------------------
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // -------------------------
  // Keys derived from UI inputs
  // -------------------------
  late final String diseaseKey;
  late final String severityKey; // mild/moderate/severe/default

  // -------------------------
  // Loaded from JSON
  // -------------------------
  Map<String, String> displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
  Map<String, String> description = const {"en": "", "tl": ""};

  List<String> whatToDoNowEn = const [];
  List<String> whatToDoNowTl = const [];

  List<String> preventionEn = const [];
  List<String> preventionTl = const [];

  List<String> whenToEscalateEn = const [];
  List<String> whenToEscalateTl = const [];

  List<String> seekHelpEn = const [];
  List<String> seekHelpTl = const [];

  int? rescanAfterDays;
  Map<String, String>? rescanMessage;

  // -------------------------
  // Treatment Plan (UI tiles)
  // -------------------------
  List<TreatmentTask> _treatmentPlan = const [];
  List<TreatmentTask> get treatmentPlan => _treatmentPlan;

  // -------------------------
  // Bookmark
  // -------------------------
  bool _isBookmarked = false;
  bool get isBookmarked => _isBookmarked;

  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
    notifyListeners();
  }

  // -------------------------
  // Init: load JSON
  // -------------------------
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1) derive keys
      diseaseKey = _diseaseKeyFromName(diseaseName);
      severityKey = _severityKeyFromText(severity);

      // 2) load disease node
      final disease = await _guide.getDisease(diseaseKey);
      if (disease == null) {
        throw Exception('Disease not found in guide: $diseaseKey');
      }

      displayName = _mapLang(disease['display_name']);
      description = _mapLang(disease['description']);

      // 3) load recommendation node
      final rec = await _guide.getRecommendation(
        diseaseKey: diseaseKey,
        severityKey: severityKey,
      );

      if (rec == null) {
        throw Exception('Recommendation not found: $diseaseKey / $severityKey');
      }

      // pull lists
      whatToDoNowEn = _listLang(rec['what_to_do_now'], 'en');
      whatToDoNowTl = _listLang(rec['what_to_do_now'], 'tl');

      preventionEn = _listLang(rec['prevention'], 'en');
      preventionTl = _listLang(rec['prevention'], 'tl');

      whenToEscalateEn = _listLang(rec['when_to_escalate'], 'en');
      whenToEscalateTl = _listLang(rec['when_to_escalate'], 'tl');

      // seek_help is optional (exists only for some severities)
      seekHelpEn = _listLang(rec['seek_help'], 'en');
      seekHelpTl = _listLang(rec['seek_help'], 'tl');

      // monitoring_plan can exist at this severity level (mild/moderate/severe)
      final mp = rec['monitoring_plan'];
      if (mp is Map<String, dynamic>) {
        final d = mp['rescan_after_days'];
        if (d is num) rescanAfterDays = d.toInt();

        final msg = mp['message'];
        if (msg is Map<String, dynamic>) {
          rescanMessage = {
            'en': msg['en']?.toString() ?? '',
            'tl': msg['tl']?.toString() ?? '',
          };
        }
      } else {
        rescanAfterDays = null;
        rescanMessage = null;
      }

      // 4) build TreatmentPlan tiles from JSON (What to do now)
      _treatmentPlan = whatToDoNowEn.isNotEmpty
          ? whatToDoNowEn
              .map((t) => TreatmentTask(
                    icon: Icons.check_circle_outline,
                    title: "Action",
                    desc: t,
                  ))
              .toList(growable: false)
          : const [
              TreatmentTask(
                icon: Icons.visibility_outlined,
                title: "Monitor",
                desc: "Observe the pod and rescan after a few days.",
              )
            ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // Helpers
  // -------------------------

  // IMPORTANT: this is the only remaining "mapping" logic.
  // Better later: pass diseaseKey/severityKey directly from model label.
  String _diseaseKeyFromName(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('black pod')) return 'black_pod_disease';
    if (n.contains('pod borer')) return 'cacao_pod_borer';
    if (n.contains('mealybug')) return 'mealybug';
    if (n.contains('healthy')) return 'healthy';
    return 'healthy';
  }

  String _severityKeyFromText(String severity) {
    final s = severity.trim().toLowerCase();
    if (s.contains('mild')) return 'mild';
    if (s.contains('moderate')) return 'moderate';
    if (s.contains('severe')) return 'severe';
    return 'default'; // for healthy
  }

  Map<String, String> _mapLang(dynamic node) {
    if (node is Map<String, dynamic>) {
      return {
        'en': node['en']?.toString() ?? '',
        'tl': node['tl']?.toString() ?? '',
      };
    }
    return {'en': '', 'tl': ''};
  }

  List<String> _listLang(dynamic node, String lang) {
    if (node is Map<String, dynamic>) {
      final list = node[lang];
      if (list is List) return list.map((e) => e.toString()).toList();
    }
    return const [];
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
