import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:cacao_apps/core/storage/token_storage.dart';

class SettingsController {
  final UserRepository userRepository =UserRepository();
  Future<void> logout() async {
    await TokenStorage().clear();
    await userRepository.clearUsers();
  }
}