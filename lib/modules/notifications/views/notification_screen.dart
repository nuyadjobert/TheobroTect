import 'package:flutter/material.dart';
import '../../scan/views/scanner_screen.dart';
import '../widgets/notification_card.dart';
import '../controller/notification_controller.dart';
import '../../../core/db/user_repository.dart';
import '../../../core/db/scan_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();

    controller = NotificationController(ScanRepository());

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = await UserRepository().getCurrentUser();

    if (!mounted || user == null) return;

    await controller.loadNotifications(user.userId);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Active Alerts",
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: controller.alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You have no active scan reminders.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: controller.alerts.length,
              itemBuilder: (context, index) {
                final alert = controller.alerts[index];

                return NotificationCard(
                  disease: alert['disease']!,
                  severity: alert['severity']!,
                  date: alert['date']!,
                  sector: alert['sector']!,
                  onIgnore: () async {
                    await controller.dismissAlert(index);
                  },
                  onRescan: () async {
                    await controller.rescanAlert(index);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScannerScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
