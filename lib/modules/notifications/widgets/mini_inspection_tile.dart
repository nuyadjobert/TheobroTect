import 'package:flutter/material.dart';

class MiniInspectionTile extends StatelessWidget {
  final String title;
  final VoidCallback onScanTap;

  const MiniInspectionTile({
    super.key, 
    required this.title,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkGreen = Color(0xFF2D6A4F);
    const Color alertColor = Color(0xFFE67E22);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Alert Icon with soft background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.report_problem_rounded,
              color: alertColor, 
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          
          // Main Text Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1B4332), 
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.priority_high_rounded, size: 10, color: alertColor.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      "HIGH PRIORITY",
                      style: TextStyle(
                        fontSize: 10, 
                        color: alertColor.withOpacity(0.9),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Buttons Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onScanTap, // Triggers the direct scan navigation
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryDarkGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryDarkGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Text(
                    "Scan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  // Logic for dismissal could go here
                  debugPrint("Dismissed: $title");
                },
                child: Text(
                  "Dismiss",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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