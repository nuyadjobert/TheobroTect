import 'package:cacao_apps/core/services/device_id_sevices.dart';
import 'package:cacao_apps/modules/scan/controllers/scan_result_controller.dart';
import 'package:cacao_apps/modules/scan/model/scan_result_model.dart';
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

  @override
  void initState() {
    super.initState();
    controller = ScanResultController(
      diseaseName: widget.result.diseaseName,
      confidence: widget.result.confidence,
      severity: widget.result.severity,
      imagePath: widget.result.imagePath,
    );
    
    // Initialize data but REMOVED the .then((_) => _autoSaveScan())
    controller.init();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  // Helper method for the manual save trigger
  Future<void> _handleManualSave() async {
    HapticFeedback.mediumImpact();
    final deviceId = await DeviceIdService().getOrCreate();
    final ok = await controller.saveScanRecord(
      userId: "default_user",
      deviceId: deviceId,
      smsEnabled: false,
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFF2D6A4F) : Colors.redAccent,
        content: Text(ok ? "Saved successfully!" : (controller.saveError ?? "Save failed")),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
            Expanded(
              flex: 2,
<<<<<<< Updated upstream
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final isBookmarked = controller.isBookmarked;
                  final isLoading = controller.isSaving;
                  final disabled = controller.isLoading || isLoading;

                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isBookmarked ? const Color(0xFF2D6A4F) : Colors.black.withAlpha(20),
                        width: 1.5,
=======
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final disabled =
                        controller.isLoading || controller.isSaving;

                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.black.withAlpha(20),
                          width: 1.5,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
>>>>>>> Stashed changes
                      ),
                      backgroundColor: isBookmarked ? const Color(0xFFE8F5E9) : Colors.white,
                      foregroundColor: isBookmarked ? const Color(0xFF2D6A4F) : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: (disabled || isBookmarked)
                        ? null
                        : _handleManualSave, // MANUAL TRIGGER
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D6A4F)))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isBookmarked ? Icons.check_circle_rounded : Icons.bookmark_add_outlined, size: 24),
                              const SizedBox(height: 2),
                              Text(isBookmarked ? "SAVED" : "SAVE", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFF4A7C59), Color(0xFF2D6A4F)]),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "SCAN AGAIN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
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