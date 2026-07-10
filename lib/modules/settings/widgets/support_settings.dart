import 'package:flutter/material.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';
import 'setting_list_tile.dart';

/// "Support" settings card: Help Center + About TheobroTect.
class SupportSettingsCard extends StatelessWidget {
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color dividerColor;

  const SupportSettingsCard({
    super.key,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            SettingsListTile(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFFBA7517),
              title: "Help Center",
              textPrimary: textPrimary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen()),
              ),
              trailing:
                  Icon(Icons.chevron_right_rounded, color: textSecondary),
            ),
            SettingsTileDivider(color: dividerColor),
            SettingsListTile(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF7F77DD),
              title: "About TheobroTect",
              textPrimary: textPrimary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              ),
              trailing:
                  Icon(Icons.chevron_right_rounded, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}