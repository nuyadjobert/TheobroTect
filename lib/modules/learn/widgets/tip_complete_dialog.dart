import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

Future<void> showTipCompletedDialog(
  BuildContext context, {
  String title = "Marked as done for today",
  String message =
      "Keep it up! Small habits like this protect your trees over time.",
  String buttonLabel = "Nice",
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => TipCompletedDialog(
      title: title,
      message: message,
      buttonLabel: buttonLabel,
    ),
  );
}

class TipCompletedDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const TipCompletedDialog({
    super.key,
    this.title = "Marked as done for today",
    this.message =
        "Keep it up! Small habits like this protect your trees over time.",
    this.buttonLabel = "Nice",
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? AppColors.nightCard : Colors.white;
    final iconCircleBg = isDark ? const Color(0xFF2D6A4F).withAlpha(45) : const Color(0xFFDCEDE1);
    final iconColor = isDark ? AppColors.forestLight : const Color(0xFF2D6A4F);
    final titleColor = isDark ? Colors.white : const Color(0xFF1B3022);
    final messageColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: iconColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: messageColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}