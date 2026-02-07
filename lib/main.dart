import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart'; 
import 'package:cacao_apps/modules/introduction/views/introduction_screen.dart';

void main() => runApp(const MyApp());

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