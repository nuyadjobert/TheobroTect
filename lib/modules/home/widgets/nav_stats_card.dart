import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NavStatsCard extends StatelessWidget {
  const NavStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.nightBg : const Color(0xFFF0F4F1);
    final trackBg = isDark ? Colors.white12 : Colors.white;
    final accentGreen = isDark ? AppColors.forestLight : const Color(0xFF2D6A4F);
    final percentColor = isDark ? Colors.greenAccent[100] : Colors.green[700];
    final titleColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white54 : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Health Score",
                style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
              ),
              Text(
                "88%",
                style: TextStyle(color: percentColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.88,
            backgroundColor: trackBg,
            color: accentGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Scanned", value: "1,240", titleColor: titleColor, labelColor: labelColor),
              _StatItem(label: "Infected", value: "42", titleColor: titleColor, labelColor: labelColor),
              _StatItem(label: "Healthy", value: "1,198", titleColor: titleColor, labelColor: labelColor),
            ],
          )
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color titleColor;
  final Color? labelColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.titleColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: labelColor)),
      ],
    );
  }
}