import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? Colors.white24 : Colors.grey.shade200;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final badgeBorderColor = isDark ? const Color(0xFF121A15) : Colors.white;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Icon(Icons.notifications_outlined, size: 24, color: iconColor),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: badgeBorderColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}