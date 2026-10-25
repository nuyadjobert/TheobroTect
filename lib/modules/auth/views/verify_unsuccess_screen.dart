import 'package:flutter/material.dart';

import 'verify_result_view.dart';

class VerifyUnsuccessScreen extends StatelessWidget {
  final String message;
  final VoidCallback onTryAgain;

  const VerifyUnsuccessScreen({
    super.key,
    required this.message,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return VerifyResultView(
      icon: Icons.close_rounded,
      color: colorScheme.error,
      iconColor: colorScheme.onError,
      sparkleColors: [colorScheme.error],
      title: 'Verification Failed',
      message: message,
      buttonLabel: 'Try Again',
      onPressed: onTryAgain,
      onBack: onTryAgain,
      errorToast: message,
    );
  }
}
