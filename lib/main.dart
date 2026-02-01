import 'package:flutter/material.dart';
import 'package:cacao_apps/screens/introduction_screen.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Keep your existing theme
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.green,
      ),
      // CHANGE THIS: Start with the Intro
// Inside your MaterialApp
home: const IntroductionScreen(),    );
  }
}