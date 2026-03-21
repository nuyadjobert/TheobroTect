import 'package:dio/dio.dart';
import '../models/request_otp_result.dart';
import '../models/verify_otp_result.dart';
import '../models/registration_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<RequestOtpResult> requestOtp(String email) async {
    try {
      final res = await _dio.post(
        '/api/theobrotect/auth/request-otp',
        data: {'email': email},
        options: Options(headers: const {"Content-Type": "application/json"}),
      );
      return RequestOtpResult.fromJson(_asMap(res.data));
    } on DioException catch (e) {
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
        '/api/theobrotect/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      // --- ADDED FOR DEBUGGING ---
    debugPrint('--- RAW BACKEND RESPONSE ---');
    debugPrint('Status Code: ${res.statusCode}');
    debugPrint('Data: ${res.data}'); 
    
    if (res.data['user'] != null) {
      debugPrint('User ID from JSON: ${res.data['user']['id']}');
      debugPrint('User Name from JSON: ${res.data['user']['name']}');
      debugPrint('Address from Server: ${res.data['user']['address']}');
debugPrint('Contact from Server: ${res.data['user']['contact_number']}'); 
    } else {
      debugPrint('WARNING: "user" object is NULL in response');
    }
    debugPrint('---------------------------');
    //
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
      '/api/theobrotect/auth/register',
      data: request.toJson(),
      options: Options(
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
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
  }

  String? _readMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null){
      return data['message'].toString();
    }
    return e.message;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Unexpected response format: ${data.runtimeType}');
  }
}
