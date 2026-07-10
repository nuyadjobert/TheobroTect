import 'package:flutter/material.dart';

/// Row of three stat tiles (overall scans / farm status / diseases
/// scanned) shown under the profile hero card.
class StatsRow extends StatelessWidget {
  final Color cardBg;
  final Color textPrimary;
  final Color textMuted;
  final int overallScans;
  final String farmStatus;
  final int diseasesScanned;

  const StatsRow({
    super.key,
    required this.cardBg,
    required this.textPrimary,
    required this.textMuted,
    required this.overallScans,
    required this.farmStatus,
    required this.diseasesScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            cardBg: cardBg,
            iconColor: const Color(0xFF378ADD),
            value: "$overallScans",
            label: "Overall scans",
            textPrimary: textPrimary,
            textMuted: textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(
            cardBg: cardBg,
            iconColor: Colors.green[600]!,
            value: farmStatus,
            label: "Farm status",
            textPrimary: textPrimary,
            textMuted: textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(
            cardBg: cardBg,
            iconColor: Colors.redAccent,
            value: "$diseasesScanned",
            label: "Diseases scanned",
            textPrimary: textPrimary,
            textMuted: textMuted,
          ),
        ),
      ],
    );
  }
}

/// Single stat tile: a bold value over a muted label.
class StatTile extends StatelessWidget {
  final Color cardBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color textPrimary;
  final Color textMuted;

  const StatTile({
    super.key,
    required this.cardBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}