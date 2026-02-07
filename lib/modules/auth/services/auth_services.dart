import 'package:dio/dio.dart';
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<void> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      await _dio.post(
        '/request-otp',
        data: {
          'phoneNumber': phoneNumber,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(e.response?.data['message'] ?? 'Server error');
    }
    return Exception('Network error');
  }
}