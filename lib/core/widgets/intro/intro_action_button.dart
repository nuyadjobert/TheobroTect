import 'package:flutter/material.dart';

class IntroActionButton extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color primaryGreen;
  final VoidCallback onPressed;

  const IntroActionButton({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.primaryGreen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          currentPage == totalPages - 1 ? "GET STARTED" : "NEXT",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}