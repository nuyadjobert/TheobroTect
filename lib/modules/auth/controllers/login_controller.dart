import 'package:flutter/material.dart';
import '../../../core/widgets/toast.dart';
import '../models/login_model.dart';
import '../services/auth_services.dart';
import '../views/verify_account_screen.dart';

class LoginController {
  final LoginModel model;
  final AuthService service;

  final TextEditingController emailController = TextEditingController();
  late final VoidCallback _emailListener;

  LoginController({
    required this.model,
    required this.service,
  }) {
    _emailListener = () {
      model.email = emailController.text;
      model.emailError = null;
    };
    emailController.addListener(_emailListener);
  }

  void dispose() {
    emailController.dispose(); 
  }

  bool validate() {
    final e = emailController.text.trim();
    model.email = e;

    if (e.isEmpty) {
      model.emailError = 'Email is required';
      return false;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(e)) {
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

    final email = model.email.trim().toLowerCase();

    try {
      model.isLoading = true;
      refresh();

      final result = await service.requestOtp(email);

      if (!context.mounted) return;
      
      if (result.status == 'OTP_SENT') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyAccountScreen(
              email: email,
              initialSeconds: result.expiresInSeconds,
            ),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      
      if (result.status == 'COOLDOWN') {
        TopToast.show(
          context,
          'Please wait ${result.retryAfterSeconds}s then try again.',
          type: ToastType.warning,
        );
        return;
      }

      if (!context.mounted) return;

      TopToast.show(
        context,
        'Request failed: ${result.status}',
        type: ToastType.error,
      );
    } catch (e) {
      if (!context.mounted) return;

      TopToast.show(context, e.toString(), type: ToastType.error);
    } finally {
      model.isLoading = false;
      refresh();
    }
  }
}