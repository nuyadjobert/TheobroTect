import 'package:flutter/material.dart';

/// Solid-fill logout button. Owns only the confirmation dialog (UI
/// concern); the actual logout + navigation work is delegated to
/// [onConfirmed] so this widget has no knowledge of controllers or auth.
class LogoutButton extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Future<void> Function() onConfirmed;

  const LogoutButton({
    super.key,
    required this.textPrimary,
    required this.textSecondary,
    required this.onConfirmed,
  });

  Future<void> _handleTap(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style:
                  TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.redAccent.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _handleTap(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Logout Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}