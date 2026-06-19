import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:cacao_apps/core/db/scan_repository.dart';
import 'package:cacao_apps/core/sync/sync_trigger.dart';
import 'package:cacao_apps/core/db/cacao_guide_repository.dart';
import 'package:cacao_apps/core/db/guide_sync_service.dart';
import 'package:cacao_apps/core/network/client.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cacao_apps/core/db/database_helper.dart';

class HomeController {
 bool _isResourcesLoaded = false;
  String? userName;
  final SyncTrigger _syncTrigger = SyncTrigger();
  
  final CacaoGuideRepository _guideRepo = CacaoGuideRepository();
  late final GuideSyncService _guideSyncService;

  HomeController() {
    _guideSyncService = GuideSyncService(
      dio: DioClient.dio,
      guideRepository: _guideRepo,
    );
  }

  // =========================================
  // NEW: Debug method to fetch data and toast
  // =========================================
  Future<void> showDatabaseDebugToast() async {
    try {
      final db = await DatabaseHelper().db;
      final rawData = await db.query('guide_diseases'); 

      if (rawData.isEmpty) {
        Fluttertoast.showToast(msg: "Database is empty!");
        return;
      }

      // Extract just the keys to keep the toast readable
      final diseaseList = rawData.map((row) => row['disease_key']).join(', ');

      Fluttertoast.showToast(
        msg: "✅ DB has ${rawData.length} diseases: $diseaseList",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error reading DB: $e");
    }
  }


  Future<void> startBackgroundServices() async {
    if (_isResourcesLoaded) return;

    try {
      await loadUserData();
      await _initializeAI();

      _isResourcesLoaded = true;
      debugPrint("TheobroTect: Background services initialized.");
    } catch (e) {
      debugPrint("TheobroTect Error: Failed to initialize services: $e");
    }
  }

  Future<void> checkPendingScans() async {
    final UserRepository userRepository = UserRepository();
    final ScanRepository scanRepository = ScanRepository();
    final user = await userRepository.getCurrentUser();

    if (user == null) {
      debugPrint("❌ [HOME] No user found");
      return;
    }

    final pending = await scanRepository.getPendingScans(userId: user.userId);
    debugPrint(" [HOME] Pending scans count: ${pending.length}");

    for (var scan in pending) {
      debugPrint(" [HOME] Pending local_id: ${scan['local_id']}");
    }
  }

  void startSync() => _syncTrigger.start();
  void stopSync() => _syncTrigger.stop();

  // UPDATED: Sync and then verify
  Future<void> syncGuideData() async {
    try {
      debugPrint('Starting guide data sync...');
      final syncSuccess = await _guideSyncService.fetchUpdatesFromServer();
      
      debugPrint('Guide sync result: $syncSuccess');

      // If sync was successful, run our test to read from SQLite
      if (syncSuccess) {
        await _verifyLocalDatabase();
        
        await showDatabaseDebugToast();
      
      }

    } catch (e) {
      debugPrint('Guide sync failed: $e');
    }
  }

 Future<void> _verifyLocalDatabase() async {
    debugPrint('\n--- 🧪 TESTING LOCAL DATABASE SAVE ---');
    
    // 1. Check total count
    final count = await _guideRepo.getDiseaseCount();
    debugPrint('Total diseases in SQLite: $count');

    // 2. Fetch all raw rows directly to get the keys
    final db = await DatabaseHelper().db;
    final rawDiseases = await db.query('guide_diseases');

    if (rawDiseases.isEmpty) {
      debugPrint('❌ FAILED: No diseases found in SQLite.');
      debugPrint('--------------------------------------\n');
      return;
    }

    // 3. Loop through every disease found in the database
    for (var row in rawDiseases) {
      final String diseaseKey = row['disease_key'] as String;
      
      // Use your repository to get the properly formatted (JSON decoded) data
      final diseaseData = await _guideRepo.getDisease(diseaseKey);

      if (diseaseData != null) {
        debugPrint('\n✅ Successfully found: $diseaseKey');
        debugPrint('   Display Name (EN): ${diseaseData['display_name']['en']}');
        debugPrint('   Display Name (TL): ${diseaseData['display_name']['tl']}');
        
        // Optional: Test fetching recommendations for this specific disease
        final mildRecs = await _guideRepo.getRecommendations(diseaseKey, 'mild');
        debugPrint('   Found ${mildRecs.length} "mild" recommendation categories.');
      } else {
        debugPrint('\n❌ FAILED: Could not decode data for $diseaseKey.');
      }
    }
    
    debugPrint('\n--------------------------------------\n');
  }
  // ... rest of your existing methods (loadUserData, getGreeting, fetchData, etc.)
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('user_full_name') ?? "Farmer";
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning,";
    if (hour >= 12 && hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  Future<void> fetchData(int index) async {
    debugPrint("TheobroTect: Fetching data for screen index $index...");
    switch (index) {
      case 0:
        await startBackgroundServices();
        break;
      case 1:
        await _fetchScanHistory();
        break;
      case 2:
        await _fetchEducationalContent();
        break;
      case 3:
        await loadUserData();
        await Future.delayed(const Duration(milliseconds: 300));
        break;
    }
  }

  Future<void> _initializeAI() async =>
      await Future.delayed(const Duration(milliseconds: 1500));
  Future<void> _fetchScanHistory() async =>
      await Future.delayed(const Duration(milliseconds: 1200));
  Future<void> _fetchEducationalContent() async =>
      await Future.delayed(const Duration(milliseconds: 1000));

        // Moved disease data from View to Controller
  final List<Map<String, dynamic>> diseaseData = [
    {
      "image": "assets/images/pb_bg.png",
      "images": [
        "assets/images/pb1.png",
        "assets/images/pb2.png",
        "assets/images/pb3.png",
      ],
      "title": "Cacao Pod Borer",
      "origin": "Southeast Asia",
      "description":
          "A small moth whose larvae tunnel into cocoa pods, disrupting bean development.",
      "symptoms": [
        "Premature ripening",
        "Uneven pod coloring",
        "Small exit holes",
        "Clumped, damaged beans",
      ],
      "tagalog": {
        "description":
            "Isang maliit na gamu-gamo kung saan ang mga uod nito ay bumubutas sa loob ng bunga ng kakaw, na sumisira sa paglaki ng mga buto.",
        "symptoms": [
          "Maagang pagkahinog ng bunga",
          "Hindi pantay na kulay ng balat",
          "Maliit na mga butas sa labas ng bunga",
          "Magkakadikit at sirang mga buto sa loob",
        ],
      },
    },
    {
      "image": "assets/images/bp_bg.png",
      "images": [
        "assets/images/bp1.png",
        "assets/images/bp2.png",
        "assets/images/bp3.png",
      ],
      "title": "Black Pod Rot",
      "origin": "Worldwide (Tropical)",
      "description":
          "Caused by Phytophthora fungi, it spreads rapidly in wet conditions.",
      "symptoms": [
        "Expanding dark brown spots",
        "White fungal growth",
        "Firm rot on pod surface",
        "Rotted internal beans",
      ],
      "tagalog": {
        "description":
            "Sanhi ng halamang-singaw na Phytophthora, mabilis itong kumakalat lalo na sa panahon ng tag-ulan o basang kapaligiran.",
        "symptoms": [
          "Lumalawak na maitim o kulay-kape na mga batik",
          "Puting amag sa ibabaw ng bunga",
          "Matigas na pagkabulok ng balat",
          "Mabahong pagkabulok ng mga buto sa loob",
        ],
      },
    },
    {
      "image": "assets/images/mb_bg.png",
      "images": [
        "assets/images/mb1.png",
        "assets/images/mb2.png",
        "assets/images/mb3.png",
      ],
      "title": "Mealybugs",
      "origin": "Global Tropics",
      "description":
          "Soft-bodied insects that suck sap and secrete honeydew, often spreading viruses.",
      "symptoms": [
        "White cottony clusters",
        "Sticky honeydew on leaves",
        "Sooty mold growth",
        "Yellowing of foliage",
      ],
      "tagalog": {
        "description":
            "Malambot na insekto na sumisipsip ng dagta ng puno at naglalabas ng malagkit na likido na nagiging sanhi ng virus.",
        "symptoms": [
          "Mapuputi at parang bulak na kumpol sa sanga o bunga",
          "Malagkit na likido sa mga dahon",
          "Pangungitim o pagkakaroon ng maitim na amag (sooty mold)",
          "Pagkapanilaw ng mga dahon",
        ],
      },
    },
  ];

}
