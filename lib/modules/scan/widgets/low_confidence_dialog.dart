import 'package:flutter/material.dart';

class LowConfidenceDialog {
  static Future<void> show(BuildContext context, {required VoidCallback onRetake}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text("Unable to Identify Disease")),
          ],
        ),
        content: const Text(
          "We couldn't identify the disease clearly. This might be due to poor lighting, "
          "blurriness, or the subject is outside the current system scope.\n\n"
          "Please retake the photo to ensure accurate recommendations.",
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onRetake();
            },
            child: const Text("Retake Photo", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}