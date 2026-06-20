import 'package:cacao_apps/core/guide/cacao_guide_service.dart';
import 'package:flutter/material.dart';
import 'save_scan_controller.dart';
import 'package:cacao_apps/core/db/cacao_guide_repository.dart';

class RecommendationItem {
  final String category;
  final List<String> content;

  RecommendationItem({
    required this.category,
    required this.content,
  });
}

class ScanResultController extends ChangeNotifier {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? imagePath;
  final CacaoGuideRepository _repository = CacaoGuideRepository();
  final CacaoGuideService _guide = CacaoGuideService();

  /// Delegate — handles all save-to-db concerns
  final SaveScanController saveScan = SaveScanController();

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
  late final String severityKey;

  // -------------------------
  // Loaded from JSON
  // -------------------------
  Map<String, String> displayName = const {
    "en": "Unknown",
    "tl": "Hindi Kilala",
  };
  Map<String, String> description = const {"en": "", "tl": ""};

  List<RecommendationItem> recommendations = [];

  int? rescanAfterDays;
  Map<String, String>? rescanMessage;

  // -------------------------
  // Treatment Plan (UI tiles)
  // -------------------------
  List<TreatmentTask> _treatmentPlan = const [];
  List<TreatmentTask> get treatmentPlan => _treatmentPlan;

  // -------------------------
  // Bookmark (derived from save state)
  // -------------------------
  bool get isBookmarked => saveScan.isSaved;
  bool get isNonCacao => diseaseKey == 'non_cacao';

  void toggleBookmark() {
    // Bookmark is now driven by saveScan.isSaved — call saveScanRecord() to save
    notifyListeners();
  }

  // -------------------------
  // Init: load guide data from JSON
  // -------------------------
  Future<void> init() async {
    _isLoading = true;
    _error = null;

    if (confidence < 0.70) {
      _error = "LOW_CONFIDENCE";
      _isLoading = false;
      notifyListeners();
      return; // Stop execution
    }
    notifyListeners();

    try {
      diseaseKey = _diseaseKeyFromName(diseaseName);
      severityKey = _severityKeyFromText(severity);

      final disease = await _guide.getDisease(diseaseKey);
      if (disease == null) {
        throw Exception('Disease not found in guide: $diseaseKey');
      }

      displayName = _mapLang(disease['display_name']);
      description = _mapLang(disease['description']);

      final recommendationRows =
          await _repository.getRecommendations(diseaseKey, severityKey);

      debugPrint("================================");
      debugPrint("RAW RECOMMENDATIONS:");
      debugPrint(recommendationRows.toString());
      debugPrint("================================");

      recommendations.clear();

      for (final row in recommendationRows) {
        final category = row['category_key']?.toString() ?? 'general';
        final content = row['content'];

        debugPrint("---------------");
        debugPrint("CATEGORY: $category");
        debugPrint("CONTENT TYPE: ${content.runtimeType}");
        debugPrint("CONTENT VALUE: $content");

        final items = _listLang(content, 'en');

        debugPrint("PARSED ITEMS: $items");

        recommendations.add(
          RecommendationItem(
            category: category,
            content: items,
          ),
        );
      }

      debugPrint("========== FINAL RESULT ==========");

      for (final rec in recommendations) {
        debugPrint("CATEGORY: ${rec.category}");
        debugPrint("CONTENT: ${rec.content}");
      }

      debugPrint("==================================");

      final allItems = recommendations.expand((e) => e.content).toList();

      _treatmentPlan = allItems.isNotEmpty
          ? allItems
              .map(
                (item) => TreatmentTask(
                  icon: Icons.check_circle_outline,
                  title: "Recommendation",
                  desc: item,
                ),
              )
              .toList(growable: false)
          : const [
              TreatmentTask(
                icon: Icons.visibility_outlined,
                title: "Monitor",
                desc: "Observe the pod and rescan after a few days.",
              ),
            ];

      _treatmentPlan = allItems.isNotEmpty
          ? allItems
              .map(
                (item) => TreatmentTask(
                  icon: Icons.check_circle_outline,
                  title: "Recommendation",
                  desc: item,
                ),
              )
              .toList(growable: false)
          : const [
              TreatmentTask(
                icon: Icons.visibility_outlined,
                title: "Monitor",
                desc: "Observe the pod and rescan after a few days.",
              ),
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
  // Save — delegates to SaveScanController
  // -------------------------
  Future<bool> saveScanRecord({bool smsEnabled = false}) {
    return saveScan.saveScanRecord(
      diseaseKey: diseaseKey,
      severityKey: severityKey,
      confidence: confidence,
      imagePath: imagePath,
      rescanAfterDays: rescanAfterDays,
      smsEnabled: smsEnabled,
      isLoading: _isLoading,
    );
  }

  // -------------------------
  // Helpers
  // -------------------------
  String _diseaseKeyFromName(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('black pod')) return 'black_pod_disease';
    if (n.contains('pod borer')) return 'cacao_pod_borer';
    if (n.contains('mealybug')) return 'mealybug';
    if (n.contains('healthy')) return 'healthy';
    if (n.contains('non_cacao') || n.contains('non cacao')) return 'non_cacao';
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
    return {'en': '', 'tl': ''};
  }

  List<String> _listLang(dynamic node, String lang) {
    debugPrint("==== _listLang ====");
    debugPrint("LANG: $lang");
    debugPrint("NODE TYPE: ${node.runtimeType}");
    debugPrint("NODE VALUE: $node");

    final List<String> results = [];

    // CASE 1
    // Current database structure:
    // [
    //   {en: "...", tl: "..."},
    //   {en: "...", tl: "..."}
    // ]
    if (node is List) {
      for (final item in node) {
        if (item is Map) {
          final value = item[lang];

          if (value != null) {
            results.add(value.toString());
          }
        }
      }

      debugPrint("RETURNING LIST: $results");
      return results;
    }

    // CASE 2
    // Alternative structure:
    // {
    //   en: [...],
    //   tl: [...]
    // }
    if (node is Map) {
      final value = node[lang];

      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }

      if (value is String) {
        return [value];
      }
    }

    debugPrint("RETURNING EMPTY LIST");
    return [];
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
