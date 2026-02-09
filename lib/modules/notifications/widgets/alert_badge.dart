import 'package:flutter/material.dart';

class AlertBadge extends StatelessWidget {
  const AlertBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF436E3B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/img1.png',
            width: 16,
            height: 16,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading img1.png: $error");
              return const Icon(
                Icons.bolt,
                size: 16,
                color: Color(0xFF436E3B),
              );
            },
          ),
          const SizedBox(width: 4),
          const Text(
            "IMMEDIATE TASK",
            style: TextStyle(
              color: Color(0xFF436E3B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}