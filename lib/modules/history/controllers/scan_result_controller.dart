import 'package:flutter/material.dart';
import 'package:cacao_apps/core/guide/cacao_guide_service.dart';

class ScanResultController extends ChangeNotifier {
  // keep these as given inputs (immutable)
  final String diseaseName;
  final double confidence;
  final String severity;

  final CacaoGuideService _guide = CacaoGuideService();

  // mutable UI state (this is what your UI should read)
  late String _diseaseName = diseaseName;
  late  String _severity = severity;
  late  double _confidence = confidence;

  String get currentDiseaseName => _diseaseName;
  String get currentSeverity => _severity;
  double get currentConfidence => _confidence;

  bool isInfected = false;
  String scanDate = DateTime.now().toIso8601String();

  // Loading state for guide fetch
  bool _isLoadingGuide = false;
  String? _guideError;

  bool get isLoadingGuide => _isLoadingGuide;
  String? get guideError => _guideError;

  // guide display (optional but useful)
  Map<String, String> displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
  Map<String, String> description = const {"en": "", "tl": ""};

  List<String> whatToDoNowEn = [];
  List<String> preventionEn = [];
  List<String> whenToEscalateEn = [];

  List<String> whatToDoNowTl = [];
  List<String> preventionTl = [];
  List<String> whenToEscalateTl = [];

  ScanResultController({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
  });

    /// Update the inputs used by initGuide() without changing existing method params.
  void setInputs({
    required String diseaseName,
    required String severity,
    double? confidence,
  }) {
    _diseaseName = diseaseName;
    _severity = severity;
    if (confidence != null) _confidence = confidence;
    notifyListeners();
  }

  Future<void> initGuide() async {
    _isLoadingGuide = true;
    _guideError = null;
    notifyListeners();

    try {
      final diseaseKey = _diseaseKeyFromName(_diseaseName);
      final severityKey = _severityKeyFromText(_severity);

      final disease = await _guide.getDisease(diseaseKey);
      if (disease == null) {
        throw Exception('Disease not found in guide: $diseaseKey');
      }

      displayName = _mapLang(disease['display_name']);
      description = _mapLang(disease['description']);

      final rec = await _guide.getRecommendation(
        diseaseKey: diseaseKey,
        severityKey: severityKey,
      );

      if (rec == null) {
        throw Exception('Recommendation not found: $diseaseKey / $severityKey');
      }

      whatToDoNowEn = _listLang(rec['what_to_do_now'], 'en');
      whatToDoNowTl = _listLang(rec['what_to_do_now'], 'tl');

      preventionEn = _listLang(rec['prevention'], 'en');
      preventionTl = _listLang(rec['prevention'], 'tl');

      whenToEscalateEn = _listLang(rec['when_to_escalate'], 'en');
      whenToEscalateTl = _listLang(rec['when_to_escalate'], 'tl');

      _isLoadingGuide = false;
      notifyListeners();
    } catch (e) {
      _guideError = e.toString();
      _isLoadingGuide = false;
      notifyListeners();
    }
  }

  void updateResults({
    required String title,
    required bool status,
    required String date,
    required Map<String, List<String>> recommendationsEn,
    required Map<String, List<String>> recommendationsTl,
  }) {
    _diseaseName = title;
    isInfected = status;
    scanDate = date;

    // Update English Lists
    whatToDoNowEn = recommendationsEn['now'] ?? [];
    preventionEn = recommendationsEn['prevention'] ?? [];
    whenToEscalateEn = recommendationsEn['escalate'] ?? [];

    // Update Tagalog Lists
    whatToDoNowTl = recommendationsTl['now'] ?? [];
    preventionTl = recommendationsTl['prevention'] ?? [];
    whenToEscalateTl = recommendationsTl['escalate'] ?? [];

    notifyListeners();
  }

  void reset() {
    _diseaseName = "Scanning...";
    isInfected = false;

    // Clear guide info too
    displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
    description = const {"en": "", "tl": ""};

    whatToDoNowEn = [];
    preventionEn = [];
    whenToEscalateEn = [];
    whatToDoNowTl = [];
    preventionTl = [];
    whenToEscalateTl = [];

    _guideError = null;
    _isLoadingGuide = false;

    notifyListeners();
  }

  // -------------------------
  // Helpers (same logic as your working module)
  // -------------------------
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
    return 'default';
  }

  Map<String, String> _mapLang(dynamic node) {
    if (node is Map<String, dynamic>) {
      return {
        'en': node['en']?.toString() ?? '',
        'tl': node['tl']?.toString() ?? '',
      };
    }
    return const {'en': '', 'tl': ''};
  }

  List<String> _listLang(dynamic node, String lang) {
    if (node is Map<String, dynamic>) {
      final list = node[lang];
      if (list is List) return list.map((e) => e.toString()).toList();
    }
    return const [];
  }
}