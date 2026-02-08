import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart'; 
import 'modules/introduction/views/introduction_screen.dart';
import 'core/network/client.dart';

void main() {
  const renderUrl = 'https://theorbrotect-backend.onrender.com';
  const localUrl = 'http://10.0.2.2:3000'; 

  const baseUrl =  bool.fromEnvironment('dart.vm.product')
      ? renderUrl      
      : localUrl;    

  DioClient.init(baseUrl: baseUrl);

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
