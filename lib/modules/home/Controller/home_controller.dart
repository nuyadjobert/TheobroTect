import 'dart:async';
import 'package:cacao_apps/core/services/notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:cacao_apps/core/db/scan_repository.dart';
import 'package:cacao_apps/core/sync/sync_trigger.dart';
import 'package:cacao_apps/core/db/cacao_guide_repository.dart';
import 'package:cacao_apps/core/db/guide_sync_service.dart';
import 'package:cacao_apps/core/network/client.dart';
import 'package:cacao_apps/core/db/database_helper.dart';
import 'package:cacao_apps/modules/home/models/disease_counts_model.dart';
import 'package:cacao_apps/modules/home/services/statistics_service.dart';

class HomeController extends ChangeNotifier {
  bool _isResourcesLoaded = false;
  String? userName;
  late final SyncTrigger _syncTrigger;

  final CacaoGuideRepository _guideRepo = CacaoGuideRepository();
  final ScanRepository _scanRepository = ScanRepository();

  late final LocalNotificationService _notificationService =
      LocalNotificationService(_scanRepository);
  late final GuideSyncService _guideSyncService;
  late final StatisticsService _statisticsService;

  DiseaseCountsModel? _diseaseCounts;
  int? _selectedYear;
  bool _isLoadingStats = false;
  StatisticsLoadState _statsLoadState = StatisticsLoadState.initial;
  String? _statsError;

  DiseaseCountsModel? get diseaseCounts => _diseaseCounts;
  int? get selectedYear => _selectedYear;
  bool get isLoadingStats => _isLoadingStats;
  StatisticsLoadState get statsLoadState => _statsLoadState;
  String? get statsError => _statsError;

  HomeController() {
    _guideSyncService = GuideSyncService(
      dio: DioClient.dio,
      guideRepository: _guideRepo,
    );
    _statisticsService = StatisticsService(dio: DioClient.dio);
    
    _syncTrigger = SyncTrigger(
      onSyncComplete: () {
        refreshStatisticsAfterSync();
      },
    );
  }

  Future<void> showDatabaseDebugToast() async {
    try {
      final db = await DatabaseHelper().db;
      final rawData = await db.query('guide_diseases');

      if (rawData.isEmpty) {
        return;
      }

      rawData.map((row) => row['disease_key']).join(', ');

    } catch (_) {}
  }

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

  Future<void> startBackgroundServices() async {
    if (_isResourcesLoaded) return;

    try {
      await loadUserData();
      await _initializeAI();

      _isResourcesLoaded = true;
    } catch (_) {}
  }

  Future<void> checkPendingScans() async {
    final UserRepository userRepository = UserRepository();
    final ScanRepository scanRepository = ScanRepository();
    final user = await userRepository.getCurrentUser();

    if (user != null) {
      await _notificationService.scheduleUserNotifications(user.userId);
    }

    if (user == null) {
      return;
    }

    await scanRepository.getPendingScans(userId: user.userId);
  }

  void startSync() => _syncTrigger.start();
  void stopSync() => _syncTrigger.stop();

  Future<void> syncGuideData() async {
    try {
      final syncSuccess = await _guideSyncService.fetchUpdatesFromServer();

      if (syncSuccess) {
        await _verifyLocalDatabase();

        await showDatabaseDebugToast();
      }
    } catch (_) {}
  }

  Future<void> _verifyLocalDatabase() async {
    final db = await DatabaseHelper().db;
    final rawDiseases = await db.query('guide_diseases');

    if (rawDiseases.isEmpty) {
      return;
    }

    for (var row in rawDiseases) {
      final String diseaseKey = row['disease_key'] as String;

      final diseaseData = await _guideRepo.getDisease(diseaseKey);

      if (diseaseData != null) {
        await _guideRepo.getRecommendations(diseaseKey, 'mild');
      }
    }
  }

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

  Future<void> loadStatistics({int? year, bool forceRefresh = false}) async {
    if (_isLoadingStats && !forceRefresh) return;

    _isLoadingStats = true;
    _selectedYear = year;
    _statsLoadState = StatisticsLoadState.loading;
    _statsError = null;
    notifyListeners();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasConnection = connectivity.any((r) => r != ConnectivityResult.none);

      if (!hasConnection) {
        _statsLoadState = StatisticsLoadState.offline;
        _statsError = 'No internet connection';
        return;
      }

      final serverReachable = await _statisticsService.isServerReachable();
      if (!serverReachable) {
        _statsLoadState = StatisticsLoadState.serverUnreachable;
        _statsError = 'Server is currently unavailable';
        return;
      }

      _diseaseCounts = await _statisticsService.getUserDiseaseCounts(year: year);

      if (_diseaseCounts!.isEmpty) {
        _statsLoadState = StatisticsLoadState.empty;
      } else {
        _statsLoadState = StatisticsLoadState.success;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _statsLoadState = StatisticsLoadState.authError;
        _statsError = 'Authentication failed';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _statsLoadState = StatisticsLoadState.serverUnreachable;
        _statsError = 'Request timed out';
      } else {
        _statsLoadState = StatisticsLoadState.error;
        _statsError = e.message ?? 'Failed to load statistics';
      }
    } catch (e) {
      _statsLoadState = StatisticsLoadState.error;
      _statsError = 'An unexpected error occurred';
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatisticsAfterSync() async {
    await loadStatistics(year: _selectedYear, forceRefresh: true);
  }

  Future<void> changeYear(int? year) async {
    if (_selectedYear == year) return;
    await loadStatistics(year: year);
  }

  Future<void> retryLoadStatistics() async {
    await loadStatistics(year: _selectedYear, forceRefresh: true);
  }
}

enum StatisticsLoadState {
  initial,
  loading,
  success,
  empty,
  offline,
  serverUnreachable,
  authError,
  error,
}
