import 'package:flutter/material.dart';

class PreventionTipCard extends StatelessWidget {
  const PreventionTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient( // Added const here
          colors: [Color(0xFF2D6A4F), Color(0xFF4A7C59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withOpacity(0.3),
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
                const Text(
                  "TODAY'S ACTION",
                  style: TextStyle(
                    color: Colors.white70, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 10, 
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sterilize your pruning tools before moving between trees.",
                  style: TextStyle(
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
              color: Colors.white.withOpacity(0.2), 
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sanitizer_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}