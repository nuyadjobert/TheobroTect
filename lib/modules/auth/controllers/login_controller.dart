import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../services/auth_services.dart';

class LoginController {
  final LoginModel model;
  final AuthService service;

  final TextEditingController emailController = TextEditingController();

  LoginController({
    required this.model,
    required this.service,
  }) {
    emailController.addListener(() {
      model.email = emailController.text;
      model.emailError = null;
    });
  }

  void dispose() {
    emailController.dispose();
  }

  bool validate() {
    final e = model.email.trim();

    if (e.isEmpty) {
      model.emailError = 'Email is required';
      return false;
    }
    if (!model.isEmailValid) {
      model.emailError = 'Enter a valid email';
      return false;
    }
    model.emailError = null;
    return true;
  }

  Future<void> onContinue(BuildContext context, VoidCallback refresh) async {
    if (!validate()) {
      refresh();
      return;
    }

    try {
      model.isLoading = true;
      refresh();

      // API call (optional now; remove if you haven't built backend yet)
      // await service.requestOtp(model.email.trim());

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => VerifyView(email: model.email.trim()),
      //   ),
      // );
    } finally {
      model.isLoading = false;
      refresh();
    }
  }
}
