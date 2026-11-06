import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cacao_apps/core/db/user_repository.dart'; 
import 'package:cacao_apps/core/model/user.model.dart';
import 'package:cacao_apps/core/storage/token_storage.dart';
import '../models/registration_model.dart';
import '../services/auth_services.dart';

class RegistrationController extends ChangeNotifier {
  final AuthService _auth;
  final _tokenStorage = TokenStorage();
  
  final UserRepository _userRepository = UserRepository();

  RegistrationController(this._auth);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? addressError;
  String? phoneError;

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

  bool _validateFields(RegistrationRequest req) {
    nameError = req.name.trim().isEmpty ? 'Full name is required' : null;
    addressError =
        req.address.trim().isEmpty ? 'Please select your barangay' : null;
    phoneError =
        req.contactNumber.trim().isEmpty ? 'Contact number is required' : null;
    return nameError == null && addressError == null && phoneError == null;
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

    if (!_validateFields(req)) {
      notifyListeners();
      return null;
    }

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
    
    await _userRepository.clearUsers();
    await _userRepository.upsertUser(localUser);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}