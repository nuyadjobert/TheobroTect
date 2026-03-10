import '../services/history_service.dart';
import 'package:cacao_apps/core/db/app_database.dart';

class HistoryController {
  final HistoryService _historyService = HistoryService();
  final AppDatabase _appDatabase = AppDatabase();

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
    final currentUser = await _appDatabase.getCurrentUser();

    if (currentUser == null) {
      return [];
    }

    return await _historyService.getHistoryByUserId(currentUser.userId);
  }

  Future<bool> deleteScan(String localId, String? imagePath) async {
    try {
      final currentUser = await _appDatabase.getCurrentUser();

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
}