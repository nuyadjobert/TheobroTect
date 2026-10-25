import 'package:flutter/material.dart';

import 'verify_result_view.dart';

class VerifySuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final String title;
  final String message;

  const VerifySuccessScreen({
    super.key,
    required this.onContinue,
    this.title = 'Email Verified!',
    this.message = 'Your email address has been\nverified successfully.',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return VerifyResultView(
      icon: Icons.check_rounded,
      color: colorScheme.primary,
      iconColor: colorScheme.onPrimary,
      sparkleColors: [colorScheme.primary, colorScheme.secondary],
      title: title,
      message: message,
      buttonLabel: 'Continue',
      onPressed: onContinue,
    );
  }
}
