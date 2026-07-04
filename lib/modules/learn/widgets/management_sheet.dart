import 'package:flutter/material.dart';
import '../models/guide_model.dart';
import '../../../theme/app_theme.dart';

class ManagementSheet extends StatefulWidget {
  final String title;
  final List<GuideStep> steps;

  const ManagementSheet({super.key, required this.title, required this.steps});

  @override
  State<ManagementSheet> createState() => _ManagementSheetState();
}

class _ManagementSheetState extends State<ManagementSheet> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.nightCard : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final closeIconColor = isDark ? Colors.white70 : Colors.black;
    final progressTrackColor = isDark ? Colors.white12 : Colors.grey.shade100;
    final iconCircleBg = isDark ? AppColors.nightBg : const Color(0xFFF0F4F1);
    final accentGreen = isDark ? AppColors.forestLight : const Color(0xFF2D6A4F);
    final descriptionColor = isDark ? Colors.white70 : Colors.grey.shade600;

    final step = widget.steps[currentStep];
    final bool isLastStep = currentStep == widget.steps.length - 1;
    final bool isFirstStep = currentStep == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: closeIconColor)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / widget.steps.length,
            backgroundColor: progressTrackColor,
            color: accentGreen,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 32),
          // Step Icon
          CircleAvatar(
            radius: 40,
            backgroundColor: iconCircleBg,
            child: Icon(step.icon, size: 36, color: accentGreen),
          ),
          const SizedBox(height: 24),
          Text("Step ${currentStep + 1}: ${step.title}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 12),
          Text(step.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: descriptionColor, height: 1.5)),
          const SizedBox(height: 40),

          // Navigation Buttons (Previous + Next)
          Row(
            children: [
              if (!isFirstStep) ...[
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => setState(() => currentStep--),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Previous",
                        style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastStep) {
                        Navigator.pop(context);
                      } else {
                        setState(() => currentStep++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isLastStep ? "Got it!" : "Next Step",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}