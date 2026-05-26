import 'package:flutter/material.dart';
import '../../../core/db/cacao_guide_repository.dart';
class ScanResultController extends ChangeNotifier {
  // Keep these as given inputs
  final String diseaseName;
  final double confidence;
  final String severity;

  // 1. Initialize your new SQLite Repository
  final CacaoGuideRepository _guideRepo = CacaoGuideRepository();

  late String _diseaseName = diseaseName;
  late String _severity = severity;
  late double _confidence = confidence;

  String get currentDiseaseName => _diseaseName;
  String get currentSeverity => _severity;
  double get currentConfidence => _confidence;

  bool isInfected = false;
  String scanDate = DateTime.now().toIso8601String();

  bool _isLoadingGuide = false;
  String? _guideError;

  bool get isLoadingGuide => _isLoadingGuide;
  String? get guideError => _guideError;

  // Guide display variables
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

  // ---------------------------------------------------------
  // NEW: Hydrate from History using relational DB keys
  // ---------------------------------------------------------
  Future<void> loadFromHistory(Map<String, dynamic> scanRow) async {
    // Override the current controller state with the DB row
    _diseaseName = scanRow['disease_key']; // Or whatever you map it to
    _severity = scanRow['severity_key'];
    _confidence = scanRow['confidence'] ?? 0.0;
    scanDate = scanRow['scanned_at'];
    isInfected = _diseaseName != 'healthy' && _diseaseName != 'non_cacao';
    
    // Now just fetch the latest text from the SQLite Guide tables!
    await initGuide();
  }

  // ---------------------------------------------------------
  // NEW: Fetch from SQLite instead of JSON
  // ---------------------------------------------------------
  Future<void> initGuide() async {
    _isLoadingGuide = true;
    _guideError = null;
    notifyListeners();

    try {
      final diseaseKey = _diseaseKeyFromName(_diseaseName);
      final severityKey = _severityKeyFromText(_severity);

      isInfected = diseaseKey != 'healthy' && diseaseKey != 'non_cacao';

      // 1. Fetch Disease Info from DB
      final diseaseInfo = await _guideRepo.getDisease(diseaseKey);
      if (diseaseInfo == null) {
        throw Exception('Disease not found in SQLite: $diseaseKey');
      }

      // Convert dynamic Map to strict String Map
      displayName = Map<String, String>.from(diseaseInfo['display_name']);
      description = Map<String, String>.from(diseaseInfo['description']);

      // 2. Fetch Recommendations from DB
      final recsList = await _guideRepo.getRecommendations(diseaseKey, severityKey);

      // Clear existing lists before populating
      whatToDoNowEn.clear(); whatToDoNowTl.clear();
      preventionEn.clear(); preventionTl.clear();
      whenToEscalateEn.clear(); whenToEscalateTl.clear();

      // 3. Sort recommendations into the right UI lists based on category
      for (var rec in recsList) {
        final category = rec['category_key'].toString().toLowerCase();
        final content = rec['content'] as Map<String, dynamic>;

        final textEn = content['en']?.toString() ?? '';
        final textTl = content['tl']?.toString() ?? '';

        if (category == 'what_to_do_now' || category == 'now') {
          whatToDoNowEn.add(textEn);
          whatToDoNowTl.add(textTl);
        } else if (category == 'prevention') {
          preventionEn.add(textEn);
          preventionTl.add(textTl);
        } else if (category == 'when_to_escalate' || category == 'escalate') {
          whenToEscalateEn.add(textEn);
          whenToEscalateTl.add(textTl);
        }
      }

      _isLoadingGuide = false;
      notifyListeners();
    } catch (e) {
      _guideError = e.toString();
      _isLoadingGuide = false;
      notifyListeners();
    }
  }

  void reset() {
    _diseaseName = "Scanning...";
    isInfected = false;

    displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
    description = const {"en": "", "tl": ""};

    whatToDoNowEn.clear(); preventionEn.clear(); whenToEscalateEn.clear();
    whatToDoNowTl.clear(); preventionTl.clear(); whenToEscalateTl.clear();

    _guideError = null;
    _isLoadingGuide = false;

    notifyListeners();
  }

  // -------------------------
  // Helpers
  // -------------------------
  String _diseaseKeyFromName(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('black pod') || n.contains('black_pod')) return 'black_pod_disease';
    if (n.contains('pod borer') || n.contains('pod_borer')) return 'cacao_pod_borer';
    if (n.contains('mealybug')) return 'mealybug';
    if (n.contains('healthy')) return 'healthy';
    if (n.contains('non cacao') || n.contains('non_cacao')) return 'non_cacao';
    
    // Fallback: If it's already a clean key, return it
    return n;
  }

  String _severityKeyFromText(String severity) {
    final s = severity.trim().toLowerCase();
    if (s.contains('mild')) return 'mild';
    if (s.contains('moderate')) return 'moderate';
    if (s.contains('severe')) return 'severe';
    
    // Healthy and Non-Cacao usually default to 'default'
    return 'default'; 
  }
}