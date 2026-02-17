import 'package:flutter/material.dart';

class ScanResultController extends ChangeNotifier {
  // --- IDENTIFICATION DATA ---
  String diseaseName = "Cacao Leaf";
  bool isInfected = false;
  String scanDate = DateTime.now().toString();

  // --- RECOMMENDATION LISTS (ENGLISH) ---
  List<String> whatToDoNowEn = [];
  List<String> preventionEn = [];
  List<String> whenToEscalateEn = [];

  // --- RECOMMENDATION LISTS (TAGALOG) ---
  List<String> whatToDoNowTl = [];
  List<String> preventionTl = [];
  List<String> whenToEscalateTl = [];

  /// Call this method when a scan is completed or 
  /// when opening a previous scan from the History.
  void updateResults({
    required String title,
    required bool status,
    required String date,
    required Map<String, List<String>> recommendationsEn,
    required Map<String, List<String>> recommendationsTl,
  }) {
    diseaseName = title;
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

    // Notify the UI (RecommendationsPanel and ScanDetailsSheet) to refresh
    notifyListeners();
  }

  /// Clears the current results for a fresh scan
  void reset() {
    diseaseName = "Scanning...";
    isInfected = false;
    whatToDoNowEn = [];
    preventionEn = [];
    whenToEscalateEn = [];
    whatToDoNowTl = [];
    preventionTl = [];
    whenToEscalateTl = [];
    notifyListeners();
  }
}