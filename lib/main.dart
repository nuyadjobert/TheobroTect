import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sqflite/sqflite.dart';

import 'core/network/client.dart';
import 'core/ml/cacao_model_service.dart';
import 'core/db/app_database.dart';
import 'core/sync/sync_trigger.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  final appDb = AppDatabase();
  final db = await appDb.db;
  final tokenStorage = TokenStorage();
  await db.insert('users', {
    'user_id': 'TEST_001',
    'email': 'test@example.com',
    'created_at': DateTime.now().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  
  DioClient.init(
    baseUrl: "https://theorbrotect-backend.onrender.com",
    getToken: () => tokenStorage.get(),
  );

final syncTrigger = SyncTrigger();
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
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: const HomeScreen(),
      ),
    );
  }
}
