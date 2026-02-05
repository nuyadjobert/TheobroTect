import 'package:flutter/material.dart';

class IntroSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const IntroSkipButton({
    super.key,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(backgroundColor: Colors.white12),
          child: const Text("SKIP", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}