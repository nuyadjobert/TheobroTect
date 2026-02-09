import 'package:flutter/material.dart';

class MiniInspectionTile extends StatelessWidget {
  final String title;
  const MiniInspectionTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color primaryDarkGreen = Color(0xFF2D6A4F);
    const Color lightGreenBg = Color(0xFFF5FAF3);
    const Color alertColor = Color(0xFFE67E22); // Warm orange for warning

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // UPDATED: Warning Icon with soft Alert Background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.1), // Soft orange glow
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.report_problem_rounded, // Distinct warning/alert icon
              color: alertColor, 
              size: 22
            ),
          ),
          const SizedBox(width: 14),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1B4332), 
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "High Priority Alert", // Updated text for warning
                  style: TextStyle(
                    fontSize: 11, 
                    color: alertColor, // Text matches icon color
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionButton(
                "Scan", 
                lightGreenBg, 
                primaryDarkGreen,
              ),
              const SizedBox(width: 8),
              _actionButton(
                "Dismiss", 
                const Color(0xFFF1F1F1), 
                Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color text) {
    return GestureDetector(
      onTap: () => print("$label tapped"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}