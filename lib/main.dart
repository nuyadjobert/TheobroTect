import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart'; 
import 'modules/introduction/views/introduction_screen.dart';
import 'modules/home/views/home_screen.dart';
import 'core/network/client.dart';

void main() {
  DioClient.init(baseUrl: 'http://10.0.2.2:5000'); // Android emulator
  // DioClient.init(baseUrl: 'http://localhost:5000'); // iOS simulator
  // DioClient.init(baseUrl: 'http://192.168.1.xxx:5000'); // real device

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        home: const IntroductionScreen(),
      ),
    );
  }
}
