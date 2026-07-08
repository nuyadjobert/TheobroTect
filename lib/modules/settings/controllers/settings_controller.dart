import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:cacao_apps/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/model/user.model.dart';

class SettingsController {
  final UserRepository userRepository =UserRepository();
  // settings_controller.dart
Future<void> logout() async {
  try {
    await TokenStorage().clear();
    await userRepository.clearUsers();
  } catch (e) {
    debugPrint("Logout Error: $e");
    // Optionally: clear storage anyway even if DB fails
    await TokenStorage().clear(); 
  }
}

Future<LocalUser?> getCurrentUser() async {
  try {
    return await userRepository.getCurrentUser();
  } catch (e) {
    debugPrint("Error fetching current user: $e");
    return null;
  }
}
}