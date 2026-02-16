import '../services/history_service.dart';

class HistoryController {
  final HistoryService _historyService = HistoryService();

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
    return await _historyService.getHistory();
  }

  Future<bool> deleteScan(int id, String? imagePath) async {
    try {
      await _historyService.deleteScan(id, imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }
}