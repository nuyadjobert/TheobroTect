import 'package:cacao_apps/core/guide/cacao_guide_service.dart';
import 'package:flutter/material.dart';
import 'save_scan_controller.dart';
import 'package:cacao_apps/core/db/cacao_guide_repository.dart';
import 'package:cacao_apps/modules/scan/model/recommendation_item.dart';
import 'package:cacao_apps/modules/scan/model/treatment_task.dart';

class ScanResultController extends ChangeNotifier {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? imagePath;
  final String? secondaryDiseaseName;
  final double? secondaryConfidence;
  final String? secondarySeverity;
  final CacaoGuideRepository _repository = CacaoGuideRepository();
  final CacaoGuideService _guide = CacaoGuideService();
  final SaveScanController saveScan = SaveScanController();

  ScanResultController({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.secondaryDiseaseName,
    this.secondaryConfidence,
    this.secondarySeverity,
    this.imagePath,
  });

  bool get hasSecondaryDisease {
    if (secondaryDiseaseName == null) return false;
    final name = secondaryDiseaseName!.trim().toLowerCase();
    if (name.isEmpty || name == 'none' || name == 'null') return false;

    if (confidence < 0.75) return false;
    if (secondaryConfidence != null && secondaryConfidence! < 0.75) return false;

    final primaryDisease = _diseaseKeyFromName(diseaseName);
    if (primaryDisease == 'healthy' && confidence >= 0.90) return false;

    return true;
  }

  Map<String, String> secondaryDisplayName = {
    "en": "",
    "tl": "",
  };

  Map<String, String> secondaryDescription = {
    "en": "",
    "tl": "",
  };

  bool _isLoading = true;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;
  late final String diseaseKey;
  late final String severityKey;

  Map<String, String> displayName = const {
    "en": "Unknown",
    "tl": "Hindi Kilala",
  };
  Map<String, String> description = const {"en": "", "tl": ""};

  List<RecommendationItem> recommendations = [];
  int? rescanAfterDays;
  Map<String, String>? rescanMessage;
  List<TreatmentTask> _treatmentPlan = const [];
  List<TreatmentTask> get treatmentPlan => _treatmentPlan;
  bool get isBookmarked => saveScan.isSaved;
  bool get isNonCacao => diseaseKey == 'non_cacao';

  void toggleBookmark() {
    // saveScan.toggleSaveRecord();
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;

    debugPrint("📱 ==== SECONDARY DETECTION LOGS ====");
    debugPrint("Raw secondaryDiseaseName: '$secondaryDiseaseName'");
    debugPrint("Raw secondaryConfidence: $secondaryConfidence");
    debugPrint("Raw secondarySeverity: '$secondarySeverity'");
    debugPrint("hasSecondaryDisease evaluates to: $hasSecondaryDisease");
    debugPrint("=======================================");

    diseaseKey = _diseaseKeyFromName(diseaseName);

    // if (diseaseKey == 'non_cacao') {
    //   _error = "NON_CACAO";
    //   _isLoading = false;
    //   notifyListeners();
    //   return; // Stop execution
    // }

    if (hasHighNonCacaoConfidence) {
      _error = "NON_CACAO";
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (confidence < 0.70) {
      _error = "LOW_CONFIDENCE";
      _isLoading = false;
      notifyListeners();
      return; // Stop execution
    }
    notifyListeners();

    try {
      severityKey = _severityKeyFromText(severity);
      final disease = await _guide.getDisease(diseaseKey);
      if (disease == null) {
        throw Exception(
          'Disease not found in guide: $diseaseKey',
        );
      }
      final monitoringPlan = await _repository.getMonitoringPlan(
        diseaseKey,
        severityKey,
      );

      if (monitoringPlan != null) {
        rescanAfterDays = monitoringPlan['rescan_after_days'] as int?;

        rescanMessage = Map<String, String>.from(
          monitoringPlan['message'] as Map,
        );

        debugPrint('========== Monitoring Plan ==========');
        debugPrint('Disease: $diseaseKey');
        debugPrint('Severity: $severityKey');
        debugPrint('Rescan After: $rescanAfterDays');
        debugPrint('Preferred Hour: ${monitoringPlan['preferred_time_hour']}');
        debugPrint('=====================================');
      } else {
        debugPrint('No monitoring plan found for $diseaseKey / $severityKey');
      }

      displayName = _mapLang(
        disease['display_name'],
      );

      description = _mapLang(
        disease['description'],
      );

      if (hasSecondaryDisease) {
        debugPrint("🔄 Loading secondary disease data from JSON...");

        final secondaryDiseaseKey = _diseaseKeyFromName(
          secondaryDiseaseName!,
        );

        final secondaryDisease = await _guide.getDisease(
          secondaryDiseaseKey,
        );

        if (secondaryDisease != null) {
          secondaryDisplayName = _mapLang(
            secondaryDisease['display_name'],
          );

          secondaryDescription = _mapLang(
            secondaryDisease['description'],
          );
          debugPrint("✅ Secondary disease loaded successfully!");
        } else {
          debugPrint(
              "⚠️ Secondary disease key '$secondaryDiseaseKey' not found in JSON guide.");
        }
      } else {
        debugPrint(
            "⏭️ Skipping secondary disease load (No valid secondary detected).");
      }

      final recommendationRows =
          await _repository.getRecommendations(diseaseKey, severityKey);

      recommendations.clear();

      for (final row in recommendationRows) {
        final category = row['category_key']?.toString() ?? 'general';
        final content = row['content'];

        final items = _listLang(content, 'en');

        recommendations.add(
          RecommendationItem(
            category: category,
            content: items,
          ),
        );
      }

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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get hasHighNonCacaoConfidence {
    // Primary prediction
    if (diseaseKey == 'non_cacao' && confidence >= 0.50) {
      return true;
    }

    // Secondary prediction
    if (secondaryDiseaseName != null) {
      final secondaryKey = _diseaseKeyFromName(secondaryDiseaseName!);

      if (secondaryKey == 'non_cacao' && (secondaryConfidence ?? 0.0) >= 0.50) {
        return true;
      }
    }

    return false;
  }
  // bool get hasHighNonCacaoConfidence {
  //   return diseaseKey == 'non_cacao' && confidence >= 0.50;
  // }

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
