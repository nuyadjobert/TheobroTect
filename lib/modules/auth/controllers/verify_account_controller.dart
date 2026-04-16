import 'package:cacao_apps/core/db/app_database.dart';
import 'package:cacao_apps/core/model/user.model.dart';
import 'package:cacao_apps/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../models/verify_otp_result.dart';
import 'dart:async';

class VerifyAccountController extends ChangeNotifier {
  final AuthService _auth;
  final String email;
  final _secureStore = TokenStorage();

  VerifyAccountController({required AuthService auth, required this.email})
    : _auth = auth;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isLoading = false;
  String? _errorMessage;
  VerifyOtpResult? _lastResult;
  bool _isVerified = false;
  bool get isVerified => _isVerified;

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

  Timer? _timer;
  int _secondsLeft = 0;

  int get secondsLeft => _secondsLeft;

  String get timerText {
    int minutes = _secondsLeft ~/ 60;
    int seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer(int seconds) {
    _timer?.cancel();
    _secondsLeft = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        notifyListeners();
      } else {
        _secondsLeft--;
        notifyListeners();
      }
    });
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  String get otp => otpControllers.map((c) => c.text).join().trim();
  bool get isOtpValid => otp.length == 6;
  bool get isNewUserRequired => _lastResult?.status == 'NEW_USER_REQUIRED';

  Future<VerifyOtpResult?> verify() async {
    clearError();

    // reset state every attempt
    _lastResult = null;
    _isVerified = false;

    if (!isOtpValid) {
      _errorMessage = 'Please enter the 6-digit code.';
      notifyListeners();
      return null;
    }

    _setLoading(true);

    try {
      final result = await _auth.verifyOtp(email: email, otp: otp);

      // ❌ backend rejected OTP
      if (result.status != 'OK') {
        _lastResult = result;
        _errorMessage = result.status == 'NEW_USER_REQUIRED'
            ? null
            : _mapStatusToMessage(result.status);
        notifyListeners();
        return result;
      }

      final token = result.token;
      final userId = result.userId;

      // ❌ missing token
      if (token == null || token.isEmpty) {
        _errorMessage = 'Missing token from server.';
        notifyListeners();
        return result;
      }

      // ❌ missing userId
      if (userId == null || userId.isEmpty) {
        _errorMessage = 'Missing userId from server.';
        notifyListeners();
        return result;
      }

      // ✅ Step 1: save token
      await _secureStore.save(token);

      // ✅ Step 2: save user locally (must succeed)
      try {
        await _saveUserLocally(
          userId: userId,
          name: result.name ?? '',
          email: result.email ?? email,
          address: result.address ?? '',
          contactNumber: result.contactNumber ?? '',
        );
      } catch (e) {
        _errorMessage = 'Failed to save user locally: $e';
        notifyListeners();
        return null;
      }

      // ✅ Step 3: mark success ONLY when EVERYTHING is OK
      _lastResult = result;
      _isVerified = true;
      _errorMessage = null;

      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> requestOtp() async {
    try {
      final result = await _auth.requestOtp(email);

      startTimer(result.expiresInSeconds ?? 200);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveUserLocally({
    required String userId,
    required String name, // Add this
    required String email,
    required String address,
    required String contactNumber,
  }) async {
    final now = DateTime.now().toIso8601String();

    final localUser = LocalUser(
      userId: userId,
      email: email,
      name: name, // Use the variable, not null!
      address: address,
      contactNumber: contactNumber,
      createdAt: now,
    );

    final db = AppDatabase();
    await db.clearUsers();
    await db.upsertUser(localUser);
  }

  // Status mapping
  String _mapStatusToMessage(String status) {
    switch (status) {
      case 'INVALID_OTP':
        return 'Invalid code. Please try again.';
      case 'OTP_EXPIRED':
        return 'Code expired. Please request a new one.';
      case 'NO_ACTIVE_OTP':
        return 'No active code. Request a new OTP.';
      case 'ACCOUNT_DELETED':
        return 'This account was deleted.';
      case 'NEW_USER_REQUIRED':
        return 'No account found. Please register.';
      default:
        return 'Verification failed: $status';
    }
  }

  @override
  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
