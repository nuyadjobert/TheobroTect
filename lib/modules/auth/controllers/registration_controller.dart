import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      _lastResponse = resp;

      switch (resp.status) {
        case RegistrationStatus.success:
          if (resp.token != null) {
            await _saveTokenLocally(resp.token!); 
          }
          await _saveNameLocally(name); 
          break;
        case RegistrationStatus.alreadyRegistered:
          _errorMessage = "This email is already registered.";
          break;
        case RegistrationStatus.invalidInput:
          _errorMessage = "Invalid input. Please check your details.";
          break;
        case RegistrationStatus.serverError:
          _errorMessage = "Server error. Please try again later.";
          break;
        case RegistrationStatus.unknown:
          _errorMessage = "Unexpected response from server.";
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

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<void> _saveTokenLocally(String token) async {
    await _tokenStorage.save(token); // ✅ uses instance not new object each time
  }

  Future<void> _saveNameLocally(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}