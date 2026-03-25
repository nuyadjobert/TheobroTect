import 'package:cacao_apps/modules/scan/controllers/scan_result_controller.dart';
import 'package:cacao_apps/modules/scan/controllers/save_scan_controller.dart';
import 'package:cacao_apps/modules/scan/controllers/location_picker_controller.dart';
import 'package:cacao_apps/modules/scan/model/scan_result_model.dart';
import 'package:cacao_apps/modules/scan/views/location_picker_screen.dart';
import 'package:cacao_apps/modules/scan/widgets/recomendation_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/severity_alert_card.dart';
import '../widgets/confidence_meter.dart';
import 'dart:io';

class ScanResultScreen extends StatefulWidget {
  final ScanResultModel result;
  const ScanResultScreen({super.key, required this.result});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late final ScanResultController controller;
  late final SaveScanController saveController;

  @override
  void initState() {
    super.initState();

    controller = ScanResultController(
      diseaseName: widget.result.diseaseName,
      confidence: widget.result.confidence,
      severity: widget.result.severity,
      imagePath: widget.result.imagePath,
    );

    saveController = SaveScanController();
    controller.init();

    // Detect location as soon as screen opens
    saveController.detectLocation().then((_) {
      if (!mounted) return;
      // If GPS is low/offline, auto-show the map picker
      if (saveController.needsManualLocation) {
        _showLocationPicker();
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    saveController.dispose();
    super.dispose();
  }

  // ─── Show the FoodPanda-style map picker ───────────────────
  Future<void> _showLocationPicker() async {
    await LocationPickerSheet.show(
      context,
      controller: saveController.locationPicker,
      initialPosition: saveController.locationPicker.pickedLatLng,
    );
  }

  // ─── Save with location guard ──────────────────────────────
  Future<void> _onSave() async {
    HapticFeedback.lightImpact();

    // If location still needs manual pin, show map first
    if (saveController.needsManualLocation) {
      final picked = await LocationPickerSheet.show(
        context,
        controller: saveController.locationPicker,
        initialPosition: saveController.locationPicker.pickedLatLng,
      );
      if (!picked || !mounted) return;
    }

    final ok = await saveController.saveScanRecord(
      diseaseKey: controller.diseaseKey,
      severityKey: controller.severityKey,
      confidence: controller.confidence,
      imagePath: controller.imagePath,
      rescanAfterDays: controller.rescanAfterDays,
      smsEnabled: false,
      isLoading: controller.isLoading,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFF2D6A4F) : Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ok
                    ? "Scan saved successfully!"
                    : (saveController.saveError ?? "Save failed"),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final lang = (langCode == "tl") ? "tl" : "en";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Result",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scanned image ──
            Hero(
              tag: 'scan_image',
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: widget.result.imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(widget.result.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/bp1.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Diagnosis ──
            const Text(
              "DIAGNOSIS",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.5,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              controller.diseaseName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B3022),
              ),
            ),
            const SizedBox(height: 16),
            SeverityAlertCard(severity: controller.severity),
            const SizedBox(height: 32),
            ConfidenceMeter(confidence: controller.confidence),
            const SizedBox(height: 32),

            // ── Location status banner ──
            _LocationStatusBanner(
              locationPicker: saveController.locationPicker,
              onTap: _showLocationPicker,
            ),
            const SizedBox(height: 24),

            // ── Treatment plan ──
            const Text(
              "Treatment Plan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3022),
              ),
            ),
            const SizedBox(height: 16),
            RecommendationsPanel(controller: controller, lang: lang),
          ],
        ),
      ),

      // ── Bottom action bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Save button ──
            Expanded(
              flex: 3,
              child: ListenableBuilder(
                listenable: Listenable.merge([controller, saveController]),
                builder: (context, _) {
                  final disabled =
                      controller.isLoading || saveController.isSaving;
                  final saved = saveController.isSaved;

                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: saved
                            ? const Color(0xFF2D6A4F)
                            : Colors.black.withAlpha(20),
                        width: 1.5,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: saved
                          ? const Color(0xFF2D6A4F)
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: disabled || saved ? null : _onSave,
                    child: saveController.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2D6A4F),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                saved
                                    ? Icons.bookmark_added_rounded
                                    : Icons.bookmark_add_outlined,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                saved ? "SAVED" : "SAVE",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // ── Scan again button ──
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A7C59), Color(0xFF2D6A4F)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "SCAN AGAIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Location status banner — shown inline above Treatment Plan
// ─────────────────────────────────────────────────────────────
class _LocationStatusBanner extends StatelessWidget {
  final LocationPickerController locationPicker;
  final VoidCallback onTap;

  const _LocationStatusBanner({
    required this.locationPicker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locationPicker,
      builder: (context, _) {
        final lp = locationPicker;

        // Still detecting
        if (lp.isLoading) {
          return _BannerTile(
            icon: Icons.gps_not_fixed,
            color: Colors.orange,
            message: "Detecting your location...",
            trailing: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            ),
          );
        }

        // Needs manual pick — tappable
        if (lp.needsManualPick) {
          return GestureDetector(
            onTap: onTap,
            child: _BannerTile(
              icon: Icons.location_off,
              color: Colors.red.shade600,
              message: lp.accuracy != null
                  ? "Low GPS accuracy (±${lp.accuracy!.toStringAsFixed(0)}m) — tap to pin"
                  : "No GPS signal — tap to pin your location",
              trailing: Icon(Icons.chevron_right, color: Colors.red.shade600, size: 20),
            ),
          );
        }

        // Manually pinned
        if (lp.isManuallyPicked) {
          return GestureDetector(
            onTap: onTap,
            child: _BannerTile(
              icon: Icons.location_on,
              color: const Color(0xFF2D6A4F),
              message: "Location pinned manually — tap to adjust",
              trailing: Icon(Icons.edit_location_alt_outlined,
                  color: const Color(0xFF2D6A4F), size: 18),
            ),
          );
        }

        // Good GPS
        final acc = lp.accuracy;
        return GestureDetector(
          onTap: onTap,
          child: _BannerTile(
            icon: Icons.gps_fixed,
            color: const Color(0xFF2D6A4F),
            message: acc != null
                ? "Location detected (±${acc.toStringAsFixed(0)}m) — tap to adjust"
                : "Location detected — tap to adjust",
            trailing: Icon(Icons.edit_location_alt_outlined,
                color: const Color(0xFF2D6A4F), size: 18),
          ),
        );
      },
    );
  }
}

class _BannerTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final Widget? trailing;

  const _BannerTile({
    required this.icon,
    required this.color,
    required this.message,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}