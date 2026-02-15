import 'package:flutter/material.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;

  const ConfidenceMeter({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
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
                color: primaryColor.withAlpha(153), // 0.6 * 255 = 153
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
                      primaryColor.withAlpha(153), // 0.6 * 255 = 153
                      primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(77), // 0.3 * 255 = 77
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
            color: primaryColor.withAlpha(26), 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                confidence >= 0.8 ? Icons.verified_user_rounded : Icons.info_outline_rounded, 
                color: primaryColor.withAlpha(255), 
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                confidence >= 0.8 ? "High confidence level" : "Moderate confidence",
                style: TextStyle(
                  color: primaryColor.withAlpha(255), 
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