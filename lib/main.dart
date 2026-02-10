import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart'; 
import 'modules/introduction/views/introduction_screen.dart';
import 'core/network/client.dart';

void main() {
  DioClient.init(baseUrl: "https://theorbrotect-backend.onrender.com");

  // Example POST
  // DioClient.dio.post("/auth/request-otp", data: {
  //   "email": "jaysonbutawan2@gmail.com",
  // }).then((response) {
  //   print("OTP sent: ${response.data}");
  // }).catchError((e) {
  //   print("Error: $e");
  // });


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
        // home: const HomeScreen(),
        home: const HomeScreen(),
      ),
    );
  }
}
