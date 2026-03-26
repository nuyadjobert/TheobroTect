import 'package:cacao_apps/modules/auth/services/auth_services.dart';
import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:cacao_apps/modules/introduction/views/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

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

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _wasOffline = false;
  bool _isBannerVisible = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOffline = results.every(
        (r) => r == ConnectivityResult.none,
      );

      if (isOffline && !_wasOffline) {
        _wasOffline = true;
        _showBanner(
          message: 'No internet connection',
          color: const Color(0xFF1B3022),
          icon: Icons.wifi_off_rounded,
          isOffline: true,
        );
      } else if (!isOffline && _wasOffline) {
        _wasOffline = false;
        _hideBanner();
        _showBackOnlineSnackbar();
      }
    });
  }

  void _showBanner({
    required String message,
    required Color color,
    required IconData icon,
    required bool isOffline,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null || _isBannerVisible) return;

    _isBannerVisible = true;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: color,
        // ✅ Reduced padding for compact size
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dividerColor: Colors.transparent,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: _hideBanner,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Dismiss',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        // ✅ Empty actions to remove the extra action row height
        actions: const [SizedBox.shrink()],
      ),
    );
  }

  void _hideBanner() {
    final context = navigatorKey.currentContext;
    if (context == null || !_isBannerVisible) return;

    _isBannerVisible = false;
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }

  void _showBackOnlineSnackbar() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Back online',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: widget.isLoggedIn ? const HomeScreen() : const IntroductionScreen(),
      routes: {
        '/notification': (_) => const NotificationScreen(),
      },
    );
  }
}