import 'package:cacao_apps/core/storage/token_storage.dart';
import 'package:cacao_apps/core/db/app_database.dart';

class SettingsController {
  Future<void> logout() async {
    await TokenStorage().clear();
    await AppDatabase().clearUsers();
  }
}