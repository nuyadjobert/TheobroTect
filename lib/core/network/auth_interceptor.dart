import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;

  AuthInterceptor(this.getToken);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();

    // ✅ Always expect JSON from backend
    options.headers['Accept'] = 'application/json';

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';

      debugPrint('🔐 Token attached');
    } else {
      debugPrint('⚠️ No token found for request: ${options.path}');
    }

    handler.next(options);
  }
}