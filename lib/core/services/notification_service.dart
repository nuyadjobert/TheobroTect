import '/core/db/scan_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import '../navigation/app_navigator.dart';

class LocalNotificationService {
  final ScanRepository repository;
  LocalNotificationService(this.repository);

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(
      tz.getLocation(timezone.identifier),
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    await requestPermission();
  }

  Future<void> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  void onNotificationTap(NotificationResponse response) {
    navigatorKey.currentState?.pushNamed('/notification');
  }

  Future<void> cancelNotification(String localId) async {
    await _notifications.cancel(
      id: localId.hashCode,
    );
  }

  Future<void> scheduleUserNotifications(String userId) async {
    print("Scheduling notification...");
    final scans = await repository.getPendingNotifications(userId);

    for (final scan in scans) {
      final localId = scan['local_id'] as String;
      final diseaseKey = scan['disease_key'] as String;
      final severityKey = scan['severity_key'] as String;

      final nextScanAt = DateTime.parse(
        scan['next_scan_at'] as String,
      );
      final now = DateTime.now();

      final isToday = nextScanAt.year == now.year &&
          nextScanAt.month == now.month &&
          nextScanAt.day == now.day;

      if (!isToday) {
        continue;
      }
      final notificationId = localId.hashCode;

      final title = buildNotificationTitle();

      final body = buildNotificationBody(
        diseaseKey: diseaseKey,
        severityKey: severityKey,
      );

      await _notifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'scan_reminders',
            'Scan Reminders',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(nextScanAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'scan_reminders',
            'Scan Reminders',
            channelDescription:
                'Reminder to perform follow-up cacao disease scans.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: localId,
      );

      log(
        "Notification successfully registered.",
        name: "Notification",
      );
    }
  }

  Future<void> scheduleNotification({
    required String localId,
    required String userId,
    required String diseaseKey,
    required String severityKey,
    required DateTime scannedAt,
    required DateTime? nextScanAt,
  }) async {
    if (nextScanAt == null) return;

    if (!nextScanAt.isAfter(DateTime.now())) return;

    final notificationId = localId.hashCode;

    final title = buildNotificationTitle();

    final body = buildNotificationBody(
      diseaseKey: diseaseKey,
      severityKey: severityKey,
    );
    await _notifications.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(nextScanAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scan_reminders',
          'Scan Reminders',
          channelDescription:
              'Reminder to perform follow-up cacao disease scans.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: localId,
    );
  }

  String buildNotificationTitle() {
    return '🌿 Time to Check Your Cacao Pod';
  }

  String buildNotificationBody({
    required String diseaseKey,
    required String severityKey,
  }) {
    return 'Your scheduled follow-up scan is due today.\n'
        'Last result: $diseaseKey ($severityKey).\n'
        'Scan the same pod to see whether its condition has improved or worsened.';
  }
}
