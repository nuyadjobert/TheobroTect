import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import './cacao_guide_repository.dart';

class GuideSyncService {
  final Dio dio;
  final CacaoGuideRepository guideRepository;

  GuideSyncService({
    required this.dio,
    required this.guideRepository,
  });

  Future<bool> fetchUpdatesFromServer() async {
    try {

      // Check if local database is empty
      final isEmpty =
          await guideRepository.isDatabaseEmpty();

      if (isEmpty) {
        debugPrint(
          'Local guide database is empty! '
          'Forcing initial download...',
        );
      } else {
        debugPrint('Checking for guide updates...');
      }

      // API REQUEST
      final response = await dio.get(
        '/api/theobrotect/disease-breakdown-view',
      );

      // STATUS VALIDATION
      if (response.statusCode == 200) {

        // RESPONSE TYPE VALIDATION
        if (response.data is! List) {

          debugPrint(
            'Invalid response format. '
            'Expected List<dynamic>',
          );

          return false;
        }

        final List<dynamic> backendPayload =
            response.data;

        // EMPTY PAYLOAD VALIDATION
        if (backendPayload.isEmpty) {

          debugPrint(
            'Server returned empty guide payload.',
          );

          return false;
        }

        // SAVE TO SQLITE
        await guideRepository.syncCacaoGuide(
          backendPayload,
        );

        // VERIFY SQLITE SAVE
        final total =
            await guideRepository.getDiseaseCount();

        debugPrint(
          'Successfully synced guide from backend!',
        );

        debugPrint(
          'Total diseases stored locally: $total',
        );

        return true;

      } else {

        debugPrint(
          'Unexpected status code: '
          '${response.statusCode}',
        );

        return false;
      }

    } on DioException catch (e) {

      debugPrint('DIO ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint(
        'Status Code: ${e.response?.statusCode}',
      );
      debugPrint('Response: ${e.response?.data}');

      final stillEmpty =
          await guideRepository.isDatabaseEmpty();

      if (stillEmpty) {

        throw Exception(
          'Initial guide download failed. '
          'Internet connection is required '
          'for first launch.',
        );
      }

      return false;

    } catch (e) {

      debugPrint('SYNC ERROR: $e');

      final stillEmpty =
          await guideRepository.isDatabaseEmpty();

      if (stillEmpty) {

        throw Exception(
          'Failed to initialize local guide database.',
        );
      }

      return false;
    }
  }
}