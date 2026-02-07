import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<RequestOtpResult> requestOtp(String email) async {
    try {
      final res = await _dio.post(
        '/request-otp',
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
        '/verify-otp',
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

class RequestOtpResult {
  final String status;
  final int? expiresInSeconds;
  final int? retryAfterSeconds;

  RequestOtpResult({
    required this.status,
    this.expiresInSeconds,
    this.retryAfterSeconds,
  });

  factory RequestOtpResult.fromJson(dynamic json) {
    final m = (json as Map).cast<String, dynamic>();
    return RequestOtpResult(
      status: m['status']?.toString() ?? 'UNKNOWN',
      expiresInSeconds: m['expires_in_seconds'] as int?,
      retryAfterSeconds: m['retry_after_seconds'] as int?,
    );
  }
}

class VerifyOtpResult {
  final String status;
  final String? token;
  final String? role;

  VerifyOtpResult({required this.status, this.token, this.role});

  factory VerifyOtpResult.fromJson(dynamic json) {
    final m = (json as Map).cast<String, dynamic>();
    return VerifyOtpResult(
      status: m['status']?.toString() ?? 'UNKNOWN',
      token: m['token']?.toString(),
      role: m['role']?.toString(),
    );
  }
}
