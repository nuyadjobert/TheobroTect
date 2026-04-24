// File: lib/core/database/repositories/user_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:cacao_apps/core/model/user.model.dart'; // Ensure correct path
import './database_helper.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> upsertUser(LocalUser user) async {
    final database = await _dbHelper.db;
    await database.delete('users');
    await database.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LocalUser?> getCurrentUser() async {
    final database = await _dbHelper.db;
    final rows = await database.query('users', limit: 1);
    if (rows.isEmpty) return null;
    return LocalUser.fromMap(rows.first);
  }

  Future<void> clearUsers() async {
    final database = await _dbHelper.db;
    await database.delete('users');
  }
}