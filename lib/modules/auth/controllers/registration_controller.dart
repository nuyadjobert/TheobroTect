import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../services/auth_services.dart';

class RegistrationController extends ChangeNotifier {
  final AuthService _auth;

  RegistrationController(this._auth);

  // =========================
  // Text field controllers
  // =========================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // =========================
  // State
  // =========================
  bool _isLoading = false;
  String? _errorMessage;
  RegistrationResponse? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegistrationResponse? get lastResponse => _lastResponse;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // Build request from fields
  // =========================
  RegistrationRequest buildRequest({
    required String email,
  }) {
    return RegistrationRequest(
      email: email,
      fullName: nameController.text,
      address: addressController.text,
      contactNumber: phoneController.text,
    );
  }

  // =========================
  // Submit registration
  // =========================
  Future<RegistrationResponse?> submitRegistration({
    required String email,
  }) async {
    _errorMessage = null;
    _lastResponse = null;

    final req = buildRequest(email: email);

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
        case RegistrationStatus.pendingApproval:
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
  bool get isRegistrationSuccessful =>
    _lastResponse?.status == RegistrationStatus.pendingApproval;


  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
