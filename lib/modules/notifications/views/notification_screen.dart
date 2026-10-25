import 'package:flutter/material.dart';

import '../../../core/db/scan_repository.dart';
import '../../../core/db/user_repository.dart';
import '../../scan/views/scanner_screen.dart';
import '../controller/notification_controller.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = NotificationController(ScanRepository());
    controller.addListener(_refresh);
    _loadNotifications();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadNotifications() async {
    final user = await UserRepository().getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      await controller.loadNotifications(user.userId);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : controller.alerts.isEmpty
              ? const _EmptyNotifications()
              : RefreshIndicator(
                  color: colors.primary,
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: controller.alerts.length + 1,
                    itemBuilder: (BuildContext context, int position) {
                      if (position == 0) {
                        return _SummaryHeader(count: controller.alerts.length);
                      }

                      final int index = position - 1;
                      final Map<String, dynamic> alert =
                          controller.alerts[index];

                      return NotificationCard(
                        disease: alert['disease']! as String,
                        severity: alert['severity']! as String,
                        date: alert['date']! as String,
                        imagePath: alert['image_path'] as String?,
                        onIgnore: () async {
                          await controller.dismissAlert(index);
                        },
                        onRescan: () async {
                          await controller.rescanAlert(index);

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ScannerScreen(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int count;

  const _SummaryHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1 ? '1 follow-up scan due' : '$count follow-up scans due',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Regular rescans help you catch changes early.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(36),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 38,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "You're all caught up",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New cacao scan reminders will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
