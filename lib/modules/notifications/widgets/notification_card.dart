import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final String disease;
  final String severity;
  final String date;
  final VoidCallback onRescan;
  final VoidCallback onIgnore;

  const NotificationCard({
    super.key,
    required this.disease,
    required this.severity,
    required this.date,
    required this.onRescan,
    required this.onIgnore,
  });

  static const Color primaryDarkGreen = Color(0xFF2D6A4F);
  static const Color deepGreen = Color(0xFF1B4332);
  static const Color clayBase = Color(0xFFEFF7EE);

  Color _severityColor() {
    switch (severity.toLowerCase()) {
      case 'severe':
        return const Color(0xFFD90429);
      case 'high':
        return const Color(0xFFE8604A); // Warm coral-red, muted
      case 'moderate':
        return const Color(0xFFE0A23D); // Muted amber
      default:
        return primaryDarkGreen; // Low severity stays fully "on brand"
    }
  }

  String formatNotificationDate(String date) {
    final dt = DateTime.parse(date);
    final now = DateTime.now();

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "Today • ${DateFormat('h:mm a').format(dt)}";
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return "Yesterday • ${DateFormat('h:mm a').format(dt)}";
    }

    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _severityColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: clayBase,
        borderRadius: BorderRadius.circular(28),
        // Dual soft shadow = claymorphism "pressed out of the surface" look.
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(230),
            offset: const Offset(-8, -8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: deepGreen.withAlpha(38),
            offset: const Offset(10, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ClayIconBadge(color: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            disease,
                            style: const TextStyle(
                              color: deepGreen,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        _SeverityPill(severity: severity, color: accent),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNotificationDate(date),
                      style: TextStyle(
                        color: deepGreen.withAlpha(140),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ClayButton(
                  label: "IGNORE",
                  onTap: onIgnore,
                  filled: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ClayButton(
                  label: "RE-SCAN",
                  onTap: onRescan,
                  filled: true,
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClayIconBadge extends StatelessWidget {
  final Color color;
  const _ClayIconBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NotificationCard.clayBase,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(230),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: color.withAlpha(70),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(Icons.eco_rounded, color: color, size: 22),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  final String severity;
  final Color color;
  const _SeverityPill({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ClayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final IconData? icon;

  const _ClayButton({
    required this.label,
    required this.onTap,
    required this.filled,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const Color green = NotificationCard.primaryDarkGreen;
    const Color deepGreen = NotificationCard.deepGreen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? green : NotificationCard.clayBase,
          borderRadius: BorderRadius.circular(16),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: green.withAlpha(90),
                    offset: const Offset(4, 6),
                    blurRadius: 12,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white.withAlpha(220),
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: deepGreen.withAlpha(30),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 15,
                  color: filled ? Colors.white : deepGreen.withAlpha(160)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : deepGreen.withAlpha(160),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
