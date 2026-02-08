import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../models/verify_otp_result.dart';

class VerifyAccountController extends ChangeNotifier {
  final AuthService _auth;
  final String email;

  VerifyAccountController({
    required AuthService auth,
    required this.email,
  }) : _auth = auth;

  // =========================
  // OTP text controllers
  // =========================
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  // =========================
  // State
  // =========================
  bool _isLoading = false;
  String? _errorMessage;
  VerifyOtpResult? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VerifyOtpResult? get lastResult => _lastResult;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // OTP helpers
  // =========================
  String get otp =>
      otpControllers.map((c) => c.text).join().trim();

  bool get isOtpValid => otp.length == 6;

  // =========================
  // Verify OTP
  // =========================
  Future<VerifyOtpResult?> verify() async {
    clearError();
    _lastResult = null;

    if (!isOtpValid) {
      _errorMessage = 'Please enter the 6-digit code.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final result = await _auth.verifyOtp(
        email: email,
        otp: otp,
      );

      _lastResult = result;

      if (result.status != 'OK') {
        _errorMessage = _mapStatusToMessage(result.status);
      }

      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // Status mapping
  // =========================
  String _mapStatusToMessage(String status) {
    switch (status) {
      case 'INVALID_OTP':
        return 'Invalid code. Please try again.';
      case 'OTP_EXPIRED':
        return 'Code expired. Please request a new one.';
      case 'NO_ACTIVE_OTP':
        return 'No active code. Request a new OTP.';
      case 'PENDING_APPROVAL':
        return 'Your account is pending approval.';
      case 'ACCOUNT_DELETED':
        return 'This account was deleted.';
      case 'NEW_USER_REQUIRED':
        return 'No account found. Please register.';
      default:
        return 'Verification failed: $status';
    }
  }

  bool get isVerified => _lastResult?.status == 'OK';

  // =========================
  // Dispose
  // =========================
  @override
  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
