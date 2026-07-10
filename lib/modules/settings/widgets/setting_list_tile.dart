import 'package:flutter/material.dart';

/// Single tappable row used inside settings cards (e.g. "My Profile",
/// "Dark Mode", "Help Center"). Shared by every settings section so the
/// icon/title/trailing layout only lives in one place.
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color textPrimary;
  final VoidCallback onTap;
  final Widget trailing;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.textPrimary,
    required this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// Thin divider inset to align with the text (not the leading icon)
/// of a [SettingsListTile] above/below it.
class SettingsTileDivider extends StatelessWidget {
  final Color color;

  const SettingsTileDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(height: 1, thickness: 0.6, color: color),
    );
  }
}