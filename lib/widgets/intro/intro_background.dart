import 'package:flutter/material.dart';

class IntroBackground extends StatelessWidget {
  final int currentPage;
  final List<Map<String, String>> introData;

  const IntroBackground({
    super.key,
    required this.currentPage,
    required this.introData,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Image.asset(
          introData[currentPage]['image']!,
          key: ValueKey<int>(currentPage),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          // Error handling for missing assets
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
        ),
      ),
    );
  }
}