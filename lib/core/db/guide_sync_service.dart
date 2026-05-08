import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import './cacao_guide_repository.dart';

class GuideSyncService {
  final Dio dio;
  final CacaoGuideRepository guideRepository;

  GuideSyncService({required this.dio, required this.guideRepository});

  Future<void> fetchUpdatesFromServer() async {
    try {
      final isEmpty = await guideRepository.isDatabaseEmpty();
      
      if (isEmpty) {
        debugPrint('Local guide database is empty! Forcing initial download...');
      } else {
        debugPrint('Checking for guide updates...');
      }

      final response = await dio.get('/api/theobrotect/disease-breakdown-view');
      
      if (response.statusCode == 200) {
        final List<dynamic> backendPayload = response.data; 
        
        await guideRepository.syncCacaoGuide(backendPayload);
        debugPrint('Successfully synced guide from backend!');
      }
    } catch (e) {
      debugPrint('Failed to fetch guide updates: $e');
      
      final stillEmpty = await guideRepository.isDatabaseEmpty();
      if (stillEmpty) {
        throw Exception("Initial guide download failed. Internet connection is required for first launch.");
      }
    }
  }
}