import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static late final Dio dio;

  static void init({required String baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 🔍 Add logging interceptor (DEBUG ONLY)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('➡️ REQUEST');
          debugPrint('➡️ ${options.method} ${options.baseUrl}${options.path}');
          debugPrint('➡️ Headers: ${options.headers}');
          debugPrint('➡️ Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ RESPONSE');
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('✅ Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ DIO ERROR');
          debugPrint('❌ Type: ${e.type}');
          debugPrint('❌ URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
          debugPrint('❌ Status: ${e.response?.statusCode}');
          debugPrint('❌ Response: ${e.response?.data}');
          debugPrint('❌ Message: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}
