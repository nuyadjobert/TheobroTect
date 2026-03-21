import 'package:cacao_apps/modules/auth/services/auth_services.dart';
import 'package:cacao_apps/modules/introduction/views/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'modules/home/views/home_screen.dart';

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

  ShowcaseView.register();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),

      home: const IntroductionScreen(),
      routes: {
        '/notification': (_) => const NotificationScreen(),
      },
    );
  }
}