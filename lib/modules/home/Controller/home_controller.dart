import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController {
  bool _isResourcesLoaded = false;
  String? userName;

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

  Future<void> _initializeAI() async => await Future.delayed(const Duration(milliseconds: 1500));
  Future<void> _fetchScanHistory() async => await Future.delayed(const Duration(milliseconds: 1200));
  Future<void> _fetchEducationalContent() async => await Future.delayed(const Duration(milliseconds: 1000));
}