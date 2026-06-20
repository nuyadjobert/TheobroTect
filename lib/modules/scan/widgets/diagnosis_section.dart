import 'package:flutter/material.dart';
import '../widgets/severity_alert_card.dart';
import '../widgets/confidence_meter.dart';

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
        const Text(
          "DIAGNOSIS",
          style: TextStyle(
            color: Colors.grey,
            letterSpacing: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          diseaseName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B3022),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B3022),
          ),
        ),
        const SizedBox(height: 16),
        SeverityAlertCard(severity: severity),
        const SizedBox(height: 32),
        ConfidenceMeter(confidence: confidence),
      ],
    );
  }
}