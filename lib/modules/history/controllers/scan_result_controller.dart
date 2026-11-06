import 'package:flutter/material.dart';
import '../../../core/db/cacao_guide_repository.dart';
import '../../scan/model/recommendation_item.dart';
class ScanResultController extends ChangeNotifier {
  final String diseaseName;
  final double confidence;
  final String severity;

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

  Map<String, String> displayName = const {"en": "Unknown", "tl": "Hindi Kilala"};
  Map<String, String> description = const {"en": "", "tl": ""};

  List<String> whatToDoNowEn = [];
  List<String> preventionEn = [];
  List<String> whenToEscalateEn = [];

  List<String> whatToDoNowTl = [];
  List<String> preventionTl = [];
  List<String> whenToEscalateTl = [];

  List<RecommendationItem> recommendations = [];

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

  Future<void> loadFromHistory(Map<String, dynamic> scanRow) async {
    _diseaseName = scanRow['disease_key'];
    _severity = scanRow['severity_key'];
    _confidence = scanRow['confidence'] ?? 0.0;
    scanDate = scanRow['scanned_at'];
    isInfected = _diseaseName != 'healthy' && _diseaseName != 'non_cacao';
    
    await initGuide();
  }

  Future<void> initGuide() async {
    _isLoadingGuide = true;
    _guideError = null;
    notifyListeners();

    try {
      final diseaseKey = _diseaseKeyFromName(_diseaseName);
      final severityKey = _severityKeyFromText(_severity);

      isInfected = diseaseKey != 'healthy' && diseaseKey != 'non_cacao';

      final diseaseInfo = await _guideRepo.getDisease(diseaseKey);
      if (diseaseInfo == null) {
        throw Exception('Disease not found in SQLite: $diseaseKey');
      }

      displayName = Map<String, String>.from(diseaseInfo['display_name']);
      description = Map<String, String>.from(diseaseInfo['description']);

      final recsList = await _guideRepo.getRecommendations(diseaseKey, severityKey);

      whatToDoNowEn.clear(); whatToDoNowTl.clear();
      preventionEn.clear(); preventionTl.clear();
      whenToEscalateEn.clear(); whenToEscalateTl.clear();
      recommendations.clear();

      for (var rec in recsList) {
        final category = rec['category_key'].toString().toLowerCase();
        final content = rec['content'];

        final itemsEn = _extractLang(content, 'en');
        final itemsTl = _extractLang(content, 'tl');

        recommendations.add(RecommendationItem(
          category: category,
          contentEn: itemsEn,
          contentTl: itemsTl,
        ));

        if (category == 'what_to_do_now' || category == 'now') {
          whatToDoNowEn.addAll(itemsEn);
          whatToDoNowTl.addAll(itemsTl);
        } else if (category == 'prevention') {
          preventionEn.addAll(itemsEn);
          preventionTl.addAll(itemsTl);
        } else if (category == 'when_to_escalate' || category == 'escalate') {
          whenToEscalateEn.addAll(itemsEn);
          whenToEscalateTl.addAll(itemsTl);
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
    recommendations.clear();

    _guideError = null;
    _isLoadingGuide = false;

    notifyListeners();
  }

  String _diseaseKeyFromName(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('black pod') || n.contains('black_pod')) return 'black_pod_disease';
    if (n.contains('pod borer') || n.contains('pod_borer')) return 'cacao_pod_borer';
    if (n.contains('mealybug')) return 'mealybug';
    if (n.contains('healthy')) return 'healthy';
    if (n.contains('non cacao') || n.contains('non_cacao')) return 'non_cacao';
    
    return n;
  }

  String _severityKeyFromText(String severity) {
    final s = severity.trim().toLowerCase();
    if (s.contains('mild')) return 'mild';
    if (s.contains('moderate')) return 'moderate';
    if (s.contains('severe')) return 'severe';
    
    return 'default'; 
  }

  List<String> _extractLang(dynamic node, String lang) {
    final List<String> results = [];

    if (node is List) {
      for (final item in node) {
        if (item is Map) {
          final value = item[lang];
          if (value is List) {
            results.addAll(value.map((e) => e.toString()));
          } else if (value != null) {
            results.add(value.toString());
          }
        } else if (item is String) {
          results.add(item);
        }
      }
      return results;
    }

    if (node is Map) {
      final value = node[lang];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        return [value];
      }

      for (final entry in node.entries) {
        if (entry.value is Map) {
          final inner = _extractLang(entry.value, lang);
          if (inner.isNotEmpty) {
            results.addAll(inner);
          }
        }
      }
    }

    return results;
  }
}