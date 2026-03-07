import 'package:uuid/uuid.dart';
import 'package:cacao_apps/modules/scan/services/scan_repository.dart';
import 'package:cacao_apps/core/guide/cacao_guide_service.dart';
import 'package:cacao_apps/core/services/notification_service.dart';

class ReminderService {
  final ScanRepository _scanRepository;
  final CacaoGuideService _guideService;
  final NotificationService _notificationService;
  final Uuid _uuid;

  ReminderService({
    ScanRepository? scanRepository,
    CacaoGuideService? guideService,
    NotificationService? notificationService,
    Uuid? uuid,
  }) : _scanRepository = scanRepository ?? ScanRepository(),
       _guideService = guideService ?? CacaoGuideService(),
       _notificationService =
           notificationService ?? NotificationService.instance,
       _uuid = uuid ?? const Uuid();

  int _notificationIdFromLocalId(String localId) {
    return localId.hashCode & 0x7fffffff;
  }

  Future<String> saveScanWithReminderFromLabel({
    required String userId,
    required String modelLabel,
    required double confidence,
    String? imagePath,
    double? locationLat,
    double? locationLng,
    double? locationAccuracy,
    String? locationLabel,
    String languageCode = 'en',
  }) async {
    final parsed = _guideService.parseModelLabel(modelLabel);
    final diseaseKey = parsed['diseaseKey']!;
    final severityKey = parsed['severityKey']!;

    final scannedAt = DateTime.now();

    final days = await _guideService.getRescanAfterDays(
      diseaseKey: diseaseKey,
      severityKey: severityKey,
    );

    final preferredHour = await _guideService.getPreferredTimeHour(
      diseaseKey: diseaseKey,
      severityKey: severityKey,
    );

    final baseDate = scannedAt.add(Duration(days: days));

    final nextScanAt = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      preferredHour,
    );

    final localId = _uuid.v4();
    final notifLocalId = _notificationIdFromLocalId(localId);

    await _scanRepository.insertScan(
      userId: userId,
      diseaseKey: diseaseKey,
      severityKey: severityKey,
      confidence: confidence,
      imagePath: imagePath,
      scannedAt: scannedAt,
      nextScanAt: nextScanAt,
      notifLocalId: notifLocalId,
      locationLat: locationLat,
      locationLng: locationLng,
      locationAccuracy: locationAccuracy,
      locationLabel: locationLabel,
      idempotencyKey: _uuid.v4(),
    );

    final diseaseName = await _guideService.getDisplayName(
      diseaseKey: diseaseKey,
      languageCode: languageCode,
    );

    final reminderMessage = await _guideService.getReminderMessage(
      diseaseKey: diseaseKey,
      severityKey: severityKey,
      languageCode: languageCode,
    );

    await _notificationService.scheduleReminder(
      notificationId: notifLocalId,
      scheduledAt: nextScanAt,
      title: 'Scan Reminder: $diseaseName',
      body: reminderMessage,
      payload: '{"local_id":"$localId","type":"scan_reminder"}',
    );

    return localId;
  }
}
