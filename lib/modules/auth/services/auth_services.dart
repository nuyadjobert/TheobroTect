import 'package:dio/dio.dart';
import '../models/request_otp_result.dart';
import '../models/verify_otp_result.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<RequestOtpResult> requestOtp(String email) async {
    try {
      final res = await _dio.post(
        '/auth/request-otp',
        data: {'email': email},
      );

      return RequestOtpResult.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(_readServerStatus(e) ?? 'Network/Server error');
    }
  }

  Future<VerifyOtpResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      return VerifyOtpResult.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(_readServerStatus(e) ?? 'Network/Server error');
    }
  }

  String? _readServerStatus(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['status'] != null) return data['status'].toString();
    return null;
  }
}