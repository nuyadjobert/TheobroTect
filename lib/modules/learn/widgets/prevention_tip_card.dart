import 'package:flutter/material.dart';

class PreventionTipCard extends StatelessWidget {
  final String label;
  final String message;
  final IconData icon;

  const PreventionTipCard({
    super.key,
    this.label = "TODAY'S ACTION",
    this.message =
        "Sterilize your pruning tools before moving between trees.",
    this.icon = Icons.sanitizer_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF4A7C59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withAlpha(77), // 0.3 * 255 = 77
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}