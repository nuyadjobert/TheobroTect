import 'package:flutter/material.dart';
import 'severity_badge.dart';

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

    final int confidencePercentage = (confidence * 100).toInt();
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
            
            // ─── DYNAMIC CLAYMORPHISM BADGE ───
            // The Container wrapper is completely removed.
            // SeverityBadge handles all its own styling now!
            SeverityBadge(severity: severity),
            
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF2F5F3),
                Color(0xFFE0E5E1),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD1D6D2),
                offset: Offset(6, 6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-6, -6),
                blurRadius: 12,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            children: [
              // Header Row for the meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded, // AI/Sparkle icon
                        size: 18,
                        color: Color(0xFF10B981), // Emerald green
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "AI Confidence",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A6353),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "$confidencePercentage%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3022),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // The Progress Bar Track & Fill
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D6D2), // Darker matte background (looks pressed in)
                  borderRadius: BorderRadius.circular(12),
                  // Subtle inner shadow effect
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000), // Very faint black inside
                      offset: Offset(0, 2),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        // Width dynamically calculates based on confidence double
                        width: constraints.maxWidth * confidence.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF34D399), // Light emerald highlight
                              Color(0xFF10B981), // Core emerald
                            ],
                          ),
                          // Give the fill bar its own mini pop-out shadow
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3310B981),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── CLAYMORPHISM DESCRIPTION CARD ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32), // Exaggerated roundness for clay
            // The volumetric clay gradient
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF), // Top-left light catch
                Color(0xFFF2F5F3), // Matte base
                Color(0xFFE0E5E1), // Bottom-right subtle depth
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            // Floating shadows
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD1D6D2), // Darker lower shadow
                offset: Offset(8, 8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.white, // Lighter upper shadow
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
            ],
            // Thick border acts as a high-contrast rim light
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-header with a mini-clay button effect
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EDE9),
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Color(0xFFD1D6D2),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF4A6353),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "About this condition",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A6353),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Enhanced Body Text
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6, // Crucial breathing room for clay style
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E3E33),
                ),
              ),
            ],
          ),
        ),  
      ],
    );
  }
}