import 'dart:io';
import 'package:cacao_apps/core/db/scan_repository.dart';
class HistoryService {
  final ScanRepository _scanRepository = ScanRepository();

  Future<List<Map<String, dynamic>>> getHistoryByUserId(String userId) async {
    return await _scanRepository.getHistoryByUserId(userId);
  }

  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> deleteScan({
    required String localId,
    required String userId,
    String? imagePath,
  }) async {
    await _scanRepository.deleteHistoryItem(
      localId: localId,
      userId: userId,
    );

    await deleteImageFile(imagePath);
  }
}