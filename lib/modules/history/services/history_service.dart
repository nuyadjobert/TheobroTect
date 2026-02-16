import 'dart:io';
import 'package:cacao_apps/core/db/app_database.dart';
import '../models/scan_history_model.dart';

class HistoryService {
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await AppDatabase().db;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_history',
      orderBy: 'created_at DESC',
    );
    return maps;
  }

  Future<void> deleteHistoryItem(int id) async {
    final db = await AppDatabase().db;
    await db.delete(
      'scan_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> deleteScan(int id, String? imagePath) async {
    await deleteHistoryItem(id);
    await deleteImageFile(imagePath);
  }
}