import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CacaoGuideService {
  static final CacaoGuideService _instance = CacaoGuideService._internal();
  factory CacaoGuideService() => _instance;
  CacaoGuideService._internal();

  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> loadGuide() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/data/cacao_guide.json');
    _cache = jsonDecode(jsonStr) as Map<String, dynamic>;
    return _cache!;
  }

  /// Returns the disease node map (e.g. diseases["black_pod_disease"])
  Future<Map<String, dynamic>?> getDisease(String diseaseKey) async {
    final guide = await loadGuide();
    final diseases = guide['diseases'] as Map<String, dynamic>?;
    return diseases?[diseaseKey] as Map<String, dynamic>?;
  }

  /// Returns recommendations node for a disease + severity
  /// e.g. diseases["black_pod_disease"]["recommendations"]["mild"]
  Future<Map<String, dynamic>?> getRecommendation({
    required String diseaseKey,
    required String severityKey,
  }) async {
    final disease = await getDisease(diseaseKey);
    if (disease == null) return null;

    final recs = disease['recommendations'] as Map<String, dynamic>?;
    if (recs == null) return null;

    // Healthy uses "default" in your JSON
    final key = (diseaseKey == 'healthy') ? 'default' : severityKey;

    return recs[key] as Map<String, dynamic>?;
  }
}
