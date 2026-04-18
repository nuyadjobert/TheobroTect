import 'package:cacao_apps/modules/scan/model/scan_result_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scan_result_screen.dart';
import '../controllers/scanner_controller.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final ScannerController controller;

  late AnimationController _animationController;
  late Animation<double> _animation;

  static const double _frameWidth = 300;
  static const double _frameHeight = 600; // taller than wide = portrait pod shape

  @override
  void initState() {
    super.initState();

    controller = ScannerController();
    controller.init();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onCapture() async {
    final results = await controller.captureAndAnalyze();
    if (!mounted || results == null) return;

    final result = ScanResultModel(
      diseaseName: results.diseaseName,
      confidence: results.confidence,
      severity: results.severity,
      imagePath: results.imagePath,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isPermissionGranted ||
            controller.cameraController == null ||
            !controller.cameraController!.value.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Camera Preview — full screen
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: CameraPreview(controller.cameraController!),
              ),

              // 2. Dark Overlay with rectangular cutout
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(178), // slightly darker for better contrast
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        height: _frameHeight,
                        width: _frameWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Scanning line animation + corner brackets
              Center(
                child: SizedBox(
                  height: _frameHeight,
                  width: _frameWidth,
                  child: Stack(
                    children: [
                      // Scanning line
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: _animation.value * (_frameHeight - 4),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.greenAccent,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withAlpha(128),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Corner brackets
                      _buildCorner(top: 0, left: 0),
                      _buildCorner(top: 0, right: 0),
                      _buildCorner(bottom: 0, left: 0),
                      _buildCorner(bottom: 0, right: 0),
                    ],
                  ),
                ),
              ),

              // 4. Frame size label (helps user know the crop area)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + _frameHeight / 2 + 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent.withAlpha(80)),
                    ),
                    child: const Text(
                      "FIT THE CACAO POD INSIDE",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. UI Controls (top bar + capture button)
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGlassIconButton(
                            icon: Icons.close,
                            onTap: () => Navigator.pop(context),
                          ),
                          // Title label in center
                          const Text(
                            "SCAN POD",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 13,
                            ),
                          ),
                          _buildGlassIconButton(
                            icon: controller.isFlashOn
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: controller.isFlashOn
                                ? Colors.yellow
                                : Colors.white,
                            onTap: controller.toggleFlash,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.isAnalyzing ? null : _onCapture,
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(128),
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),

              // 6. Analyzing overlay
              if (controller.isAnalyzing)
                Container(
                  color: Colors.black87,
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "ANALYZING POD...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Identifying disease patterns",
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: (top != null && left != null)
                ? const Radius.circular(16)
                : Radius.zero,
            topRight: (top != null && right != null)
                ? const Radius.circular(16)
                : Radius.zero,
            bottomLeft: (bottom != null && left != null)
                ? const Radius.circular(16)
                : Radius.zero,
            bottomRight: (bottom != null && right != null)
                ? const Radius.circular(16)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}