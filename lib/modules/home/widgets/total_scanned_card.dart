import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TotalScannedCard extends StatelessWidget {
  const TotalScannedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const Color brandGreen = Color(0xFF2D6A4F);
    final Color accentGreen = isDark ? AppColors.forestLight : brandGreen;
    final Color iconColor = isDark ? AppColors.forestLight : const Color(0xFF1B4332);

    final Color cardBg = isDark ? AppColors.nightCard : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B4332);
    final Color subtitleColor = isDark ? Colors.white60 : Colors.grey;
    final Color chevronColor = isDark ? Colors.white38 : Colors.grey;
    final Color dividerColor = isDark ? Colors.white24 : Colors.grey.withAlpha(128);
    final Color borderColor = isDark
        ? Colors.white.withAlpha(20)
        : brandGreen.withAlpha(20);
    final Color shadowColor = isDark
        ? Colors.black.withAlpha(140)
        : Colors.black.withAlpha(76);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: 38 / 45,
                      strokeWidth: 6,
                      backgroundColor: Colors.redAccent.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Icon(Icons.analytics_outlined, size: 20, color: iconColor),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Farm Health Summary",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    Text(
                      "Based on your last 45 scans",
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: chevronColor),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, thickness: 0.5, color: dividerColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnhancedStatItem("45", "Total Scans", Colors.blueGrey, subtitleColor),
              _buildEnhancedStatItem("38", "Healthy", accentGreen, subtitleColor),
              _buildEnhancedStatItem("07", "Diseased", Colors.redAccent, subtitleColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(
    String value,
    String label,
    Color color,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Container(height: 3, width: 20, decoration: BoxDecoration(color: color.withAlpha(51), borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.2)),
      ],
    );
  }
}