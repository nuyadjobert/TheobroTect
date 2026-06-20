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
        // ─── DIAGNOSIS CATEGORY TAG ───
        Text(
          "DIAGNOSIS",
          style: TextStyle(
            color: const Color(0xFF1B3022).withAlpha(153),
            letterSpacing: 1.5,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // ─── DISEASE TITLE ───
        Text(
          diseaseName,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B3022),
            letterSpacing: -0.5,
          ),
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
                      height:
                          1.5, // Injects crucial breathing room between lines
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                      color: Color(
                          0xFF2E3E33), // Softer, deeply legible deep green-charcoal
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
