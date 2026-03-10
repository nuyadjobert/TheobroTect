import 'dart:io';
import 'package:cacao_apps/core/db/app_database.dart';

class HistoryService {
  Future<List<Map<String, dynamic>>> getHistoryByUserId(String userId) async {
    final db = await AppDatabase().db;

    final List<Map<String, dynamic>> maps = await db.query(
      'scan_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps;
  }

  Future<void> deleteHistoryItem({
    required String localId,
    required String userId,
  }) async {
    final db = await AppDatabase().db;

    await db.delete(
      'scan_history',
      where: 'local_id = ? AND user_id = ?',
      whereArgs: [localId, userId],
    );
  }

  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteScan({
    required String localId,
    required String userId,
    String? imagePath,
  }) async {
    await deleteHistoryItem(
      localId: localId,
      userId: userId,
    );

    await deleteImageFile(imagePath);
  }
}