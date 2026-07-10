import '../services/history_service.dart';
import 'package:cacao_apps/core/db/user_repository.dart';

class HistoryController {
  final HistoryService _historyService = HistoryService();
  final UserRepository _userRepository = UserRepository();
  String _activeFilter = "All Scans";
  DateTime? _selectedDate;

  String get activeFilter => _activeFilter;
  DateTime? get selectedDate => _selectedDate;

  void setActiveFilter(String filter) {
    _activeFilter = filter;
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final currentUser = await _userRepository.getCurrentUser();

    if (currentUser == null) {
      return [];
    }

    return await _historyService.getHistoryByUserId(currentUser.userId);
  }

  Future<bool> deleteScan(String localId, String? imagePath) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();

      if (currentUser == null) return false;

      await _historyService.deleteScan(
        localId: localId,
        userId: currentUser.userId,
        imagePath: imagePath,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // NEW — add this method
  Future<Map<String, dynamic>> getFarmStats() async {
  final fullHistory = await getHistory();

  // Sort newest first, then take the most recent 20 (or fewer if not enough)
  final sorted = List<Map<String, dynamic>>.from(fullHistory)
    ..sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'].toString()) ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['created_at'].toString()) ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

  const int windowSize = 20;
  final recentScans = sorted.take(windowSize).toList();

  final totalScans = fullHistory.length; // overall count stays lifetime
  final recentCount = recentScans.length;

  final healthyCount = recentScans.where((item) {
    return item['severity_key'] == 'default' || item['disease_key'] == 'healthy';
  }).length;

  final diseaseKeys = fullHistory
      .where((item) => item['disease_key'] != null &&
          item['disease_key'] != 'healthy')
      .map((item) => item['disease_key'].toString())
      .toSet();

  String farmStatus;
  if (recentCount == 0) {
    farmStatus = "No data";
  } else {
    final healthyRatio = healthyCount / recentCount;

    if (healthyRatio >= 0.85) {
      farmStatus = "Excellent";
    } else if (healthyRatio >= 0.65) {
      farmStatus = "Good";
    } else if (healthyRatio >= 0.4) {
      farmStatus = "Fair";
    } else if (healthyRatio >= 0.15) {
      farmStatus = "Needs attention";
    } else {
      farmStatus = "Critical";
    }
  }

  return {
    "overallScans": totalScans,
    "farmStatus": farmStatus,
    "diseasesScanned": diseaseKeys.length,
  };
}
}