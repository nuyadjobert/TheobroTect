import 'package:dio/dio.dart';
import '../models/request_otp_result.dart';
import '../models/verify_otp_result.dart';
import '../models/registration_model.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<RequestOtpResult> requestOtp(String email) async {
    try {
      final res = await _dio.post(
        '/api/auth/request-otp',
        data: {'email': email},
        options: Options(headers: const {"Content-Type": "application/json"}),
      );
      return RequestOtpResult.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      final sc = e.response?.statusCode;
      final data = e.response?.data;
      print('requestOtp failed status=$sc data=$data error=${e.message}');
      throw Exception(
        _readServerStatus(e) ?? _readMessage(e) ?? 'Network/Server error',
      );
    }
  }

  Future<VerifyOtpResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _dio.post(
        '/api/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return VerifyOtpResult.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throw Exception(
        _readServerStatus(e) ?? _readMessage(e) ?? 'Network/Server error',
      );
    }
  }

  Future<RegistrationResponse> register(RegistrationRequest request) async {
    try {
      final res = await _dio.post(
        '/api/users/register',
        data: request.toJson(),
        options: Options(headers: const {"Content-Type": "application/json"}),
      );
      return RegistrationResponse.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throw Exception(
        _readServerStatus(e) ?? _readMessage(e) ?? 'Network/Server error',
      );
    }
  }

  String? _readServerStatus(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['status'] != null) return data['status'].toString();
    return null;
    // Examples: MISSING_TOKEN, INVALID_OTP, OTP_EXPIRED, etc.
  }

  String? _readMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    return e.message;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Unexpected response format: ${data.runtimeType}');
  }
}
