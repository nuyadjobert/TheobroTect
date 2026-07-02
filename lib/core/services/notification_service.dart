import '/core/db/scan_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    // Later:
    // Navigate to Scan History
    // or open the Scan screen.
  }
  Future<void> cancelNotification(String localId) async {
    await _notifications.cancel(
      id: localId.hashCode,
    );
  }

  Future<void> scheduleUserNotifications(String userId) async {
    final scans = await repository.getPendingNotifications(userId);

    for (final scan in scans) {
      final localId = scan['local_id'] as String;
      final diseaseKey = scan['disease_key'] as String;
      final severityKey = scan['severity_key'] as String;

      final nextScanAt = DateTime.parse(
        scan['next_scan_at'] as String,
      );

      // Skip expired reminders.
      if (!nextScanAt.isAfter(DateTime.now())) {
        continue;
      }

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
