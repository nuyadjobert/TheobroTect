import '../../core/network/client.dart';
import 'models/login_model.dart';
import 'services/auth_services.dart';
import 'controllers/login_controller.dart';
import 'views/login_screen.dart';

LoginScreen buildLoginScreen() {
  final dio = DioClient(baseUrl: 'https://your-api.com').dio;
  final model = LoginModel();
  final service = AuthService(dio);
  final controller = LoginController(model: model, service: service);

  return LoginScreen(controller: controller, model: model);
}
