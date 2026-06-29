import 'package:flutter/material.dart';
import 'dart:ui';

class DiagnosisSection extends StatelessWidget {
  final String diseaseName;
  final String description;
  final String severity;
  final double confidence;

  const DiagnosisSection({
    super.key,
    required this.diseaseName,
    required this.description,
    required this.severity,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── DISEASE TITLE & SEVERITY BADGE ───
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                diseaseName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800, 
                  color: Color(0xFF1B3022),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1), // Very light red background
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFFCDCD), // Soft red outline
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error, // Solid circle with white exclamation mark
                    color: Color(0xFFEF4444), // Vibrant red matching the image
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    severity,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ─── GLASSMORPHISM DESCRIPTION CARD ───
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // The frosted layout mix: semi-transparent white gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(166),
                    Colors.white.withAlpha(89),
                  ],
                ),
                // Subtle, crisp boundary lines mimicking real glass edges
                border: Border.all(
                  color: Colors.white.withAlpha(153),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small internal header to give the card context
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 15,
                          color: const Color(0xFF1B3022).withAlpha(153)),
                      const SizedBox(width: 6),
                      Text(
                        "About this condition",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B3022).withAlpha(153),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Enhanced Body Text Architecture
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5, // Injects crucial breathing room between lines
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E3E33), // Softer, deeply legible deep green-charcoal
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),  
      ],
    );
  }
}