import 'package:flutter/material.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor;
    Color baseBgColor;
    Color shadowBgColor;
    IconData statusIcon;

    switch (severity.toLowerCase().trim()) {
      case 'mild':
        mainColor = const Color(0xFF10B981);
        baseBgColor = const Color(0xFFECFDF5);
        shadowBgColor = const Color(0xFFD1FAE5);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'moderate':
        mainColor = const Color(0xFFF59E0B);
        baseBgColor = const Color(0xFFFFFBEB);
        shadowBgColor = const Color(0xFFFEF3C7);
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'severe':
      default:
        mainColor = const Color(0xFFEF4444);
        baseBgColor = const Color(0xFFFEF2F2);
        shadowBgColor = const Color(0xFFFEE2E2);
        statusIcon = Icons.error_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            baseBgColor,
            shadowBgColor,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: mainColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            severity.toUpperCase(),
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}