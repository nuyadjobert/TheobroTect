import 'package:flutter/material.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;

  const ConfidenceMeter({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    // Determine the color theme based on confidence level
    final Color primaryColor = confidence >= 0.8 ? const Color(0xFF2D6A4F) : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "AI Confidence",
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                color: Color(0xFF1B3022),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              "${(confidence * 100).toInt()}",
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 24,
                color: primaryColor,
                height: 1,
              ),
            ),
            Text(
              "%",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: primaryColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Modern Gradient Progress Bar
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            FractionallySizedBox(
              widthFactor: confidence,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.7),
                      primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dynamic Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                confidence >= 0.8 ? Icons.verified_user_rounded : Icons.info_outline_rounded, 
                color: primaryColor, 
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                confidence >= 0.8 ? "High confidence level" : "Moderate confidence",
                style: TextStyle(
                  color: primaryColor, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}