import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cacao_apps/core/db/app_database.dart';
import 'package:cacao_apps/core/model/user.model.dart';
import 'package:cacao_apps/core/storage/token_storage.dart';
import '../models/registration_model.dart';
import '../services/auth_services.dart';

class RegistrationController extends ChangeNotifier {
  final AuthService _auth;
  final _tokenStorage = TokenStorage();

  RegistrationController(this._auth);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  RegistrationResponse? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegistrationResponse? get lastResponse => _lastResponse;

  bool get isRegistrationSuccessful =>
      _lastResponse?.status == RegistrationStatus.success;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  RegistrationRequest buildRequest({
    required String email,
    required String name,
    required String address,
    required String contactNumber,
  }) {
    return RegistrationRequest(
      email: email,
      name: name,
      address: address,
      contactNumber: contactNumber,
    );
  }

  Future<RegistrationResponse?> submitRegistration({
    required String email,
    required String name,
    required String address,
    required String contactNumber,
  }) async {
    _errorMessage = null;
    _lastResponse = null;

    final req = buildRequest(
      email: email,
      name: name,
      address: address,
      contactNumber: contactNumber,
    );

    if (!req.isValid) {
      _errorMessage = "Please enter valid registration details.";
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final resp = await _auth.register(req);

      switch (resp.status) {
        case RegistrationStatus.success:
          if (resp.token != null) {
            await _saveTokenLocally(resp.token!);
          }

          final userId = resp.user?['id']?.toString() ?? '';
          try {
            await _saveUserLocally(
              userId: userId,
              email: email,
              name: name,
              address: address,
              contactNumber: contactNumber,
            );
          } catch (e) {
            _errorMessage = 'Failed to save user locally: $e';
            notifyListeners();
            return null;
          }

          // ✅ only mark success AFTER everything is saved
          _lastResponse = resp;
          break;

        case RegistrationStatus.alreadyRegistered:
          _errorMessage = "This email is already registered.";
          _lastResponse = resp;
          break;
        case RegistrationStatus.invalidInput:
          _errorMessage = "Invalid input. Please check your details.";
          _lastResponse = resp;
          break;
        case RegistrationStatus.serverError:
          _errorMessage = "Server error. Please try again later.";
          _lastResponse = resp;
          break;
        case RegistrationStatus.unknown:
          _errorMessage = "Unexpected response from server.";
          _lastResponse = resp;
          break;
      }

      notifyListeners();
      return resp;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }


  Future<void> _saveTokenLocally(String token) async {
    await _tokenStorage.save(token);
  }

  Future<void> _saveUserLocally({
    required String userId,
    required String email,
    required String name,
    required String address,
    required String contactNumber,
  }) async {
    final now = DateTime.now().toIso8601String();
    final localUser = LocalUser(
      userId: userId,
      email: email,
      name: name,
      address: address,
      contactNumber: contactNumber,
      createdAt: now,
    );
    final db = AppDatabase();
    await db.clearUsers();
    await db.upsertUser(localUser);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}