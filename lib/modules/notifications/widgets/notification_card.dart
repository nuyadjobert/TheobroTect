import 'dart:io';

import 'package:cacao_apps/core/utils/disease_name_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  static const Color _moderateColor = Color(0xFFF59E0B);
  static const double _thumbnailSize = 56;

  final String disease;
  final String severity;
  final String date;
  final String? imagePath;
  final VoidCallback onRescan;
  final VoidCallback onIgnore;

  const NotificationCard({
    super.key,
    required this.disease,
    required this.severity,
    required this.date,
    required this.onRescan,
    required this.onIgnore,
    this.imagePath,
  });

  Color _severityColor(ColorScheme colors) {
    switch (severity.toLowerCase().trim()) {
      case 'severe':
      case 'high':
        return colors.error;
      case 'moderate':
        return _moderateColor;
      default:
        return colors.primary;
    }
  }

  IconData _severityIcon() {
    switch (severity.toLowerCase().trim()) {
      case 'severe':
      case 'high':
        return Icons.error_rounded;
      case 'moderate':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _formatNotificationDate() {
    final DateTime? parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return 'Date unavailable';

    final DateTime dt = parsedDate.toLocal();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime alertDay = DateTime(dt.year, dt.month, dt.day);
    final String time = DateFormat('h:mm a').format(dt);

    if (alertDay == today) return 'Scanned today • $time';
    if (alertDay == today.subtract(const Duration(days: 1))) {
      return 'Scanned yesterday • $time';
    }

    return 'Scanned ${DateFormat('MMM d, yyyy • h:mm a').format(dt)}';
  }

  Widget _buildThumbnail(Color accent) {
    final Widget fallback = Container(
      width: _thumbnailSize,
      height: _thumbnailSize,
      decoration: BoxDecoration(
        color: accent.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_severityIcon(), color: accent, size: 26),
    );

    final String? path = imagePath;
    if (path == null || path.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        width: _thumbnailSize,
        height: _thumbnailSize,
        fit: BoxFit.cover,
        cacheWidth: 168,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color accent = _severityColor(colors);
    final String displayDisease = formatDiseaseName(disease);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: ColoredBox(color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbnail(accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayDisease,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _SeverityBadge(
                            severity: severity,
                            color: accent,
                            icon: _severityIcon(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _formatNotificationDate(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                        color: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Follow-up scan due. Rescan this pod to check how it is doing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool useVerticalActions = constraints.maxWidth < 260;
                    final Widget dismissButton = OutlinedButton.icon(
                      onPressed: onIgnore,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Dismiss'),
                    );
                    final Widget rescanButton = FilledButton.icon(
                      onPressed: onRescan,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Rescan'),
                    );

                    if (useVerticalActions) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          rescanButton,
                          const SizedBox(height: 8),
                          dismissButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: dismissButton),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: rescanButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;
  final IconData icon;

  const _SeverityBadge({
    required this.severity,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            severity.trim().toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
