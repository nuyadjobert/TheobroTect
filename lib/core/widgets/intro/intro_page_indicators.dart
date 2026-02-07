import 'package:flutter/material.dart';

class IntroPageIndicators extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color primaryGreen;

  const IntroPageIndicators({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentPage == index ? primaryGreen : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}