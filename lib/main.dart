import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'core/network/client.dart';
import 'core/ml/cacao_model_service.dart';
import 'core/db/app_database.dart';
import 'core/sync/sync_trigger.dart';

final SyncTrigger syncTrigger = SyncTrigger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DioClient.init(baseUrl: "https://theorbrotect-backend.onrender.com");

  await AppDatabase().db;
  await CacaoModelService().loadModel();

  await syncTrigger.start();

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
        home: const HomeScreen(),
      ),
    );
  }
}
