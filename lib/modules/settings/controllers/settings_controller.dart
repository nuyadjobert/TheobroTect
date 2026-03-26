import 'package:cacao_apps/core/storage/token_storage.dart';

class SettingsController {
  Future<void> logout() async {
    await TokenStorage().clear();
  }
}