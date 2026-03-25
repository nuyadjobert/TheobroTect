import 'package:cacao_apps/modules/auth/services/auth_services.dart';
import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:cacao_apps/modules/introduction/views/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import 'core/network/client.dart';
import 'core/storage/token_storage.dart';
import 'core/services/notification_service.dart';
import 'modules/notifications/views/notification_screen.dart';
import 'modules/auth/controllers/registration_controller.dart';
import 'modules/auth/models/registration_model.dart';
import 'core/config/app_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

late final RegistrationController controller;
late final RegistrationRequest model;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final tokenStorage = TokenStorage();
  DioClient.init(
    baseUrl: AppConfig.baseUrl,
    getToken: () => tokenStorage.get(),
  );

  await NotificationService.instance.init();

  final authService = AuthService(DioClient.dio);
  controller = RegistrationController(authService);

  // ✅ Check token before app starts
  final token = await tokenStorage.get();
  final bool isLoggedIn = token != null && token.isNotEmpty;

  ShowcaseView.register();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),

      // ✅ Route based on login state
      home: isLoggedIn ? const HomeScreen() : const IntroductionScreen(),
      routes: {
        '/notification': (_) => const NotificationScreen(),
      },
    );
  }
}