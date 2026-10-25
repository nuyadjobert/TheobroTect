import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/toast.dart';
import 'scan_result_screen.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/scanner_overlay_painter.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerController controller;

  static const double _maxFrameWidth = 280;
  static const double _maxFrameHeight = 440;
  static const double _topBarHeight = 72;
  static const double _guidanceHeight = 64;
  static const double _guidanceGap = 12;
  static const double _captureButtonSize = 84;
  static const double _bottomPadding = 16;
  static const double _framePadding = 24;

  Offset? _focusPoint;
  bool _showFocusRing = false;

  @override
  void initState() {
    super.initState();
    controller = ScannerController();
    _initialize();
  }

  Future<void> _initialize() async {
    await controller.init();
    if (!mounted) return;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onCapture() async {
    final results = await controller.captureAndAnalyze();

    if (!mounted || results == null || results.isEmpty) return;

    if (results.first.diseaseName == 'Rescan Required') {
      TopToast.show(
        context,
        results.first.severity,
        type: ToastType.error,
        duration: const Duration(seconds: 4),
      );

      return;
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          results: results,
        ),
      ),
    );
  }

  Future<void> _onTapToFocus(TapDownDetails details) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;

    final Offset point = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    setState(() {
      _focusPoint = localPosition;
      _showFocusRing = true;
    });

    HapticFeedback.selectionClick();

    await controller.cameraController?.setFocusPoint(point);
    await controller.cameraController?.setExposurePoint(point);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showFocusRing = false;
        });
      }
    });
  }

  /// Fits the pod frame into the space between the top bar and the bottom
  /// controls, scaling it down on small screens and keeping its proportions.
  Rect _frameRect(Size size, EdgeInsets padding) {
    final double top = padding.top + _topBarHeight;
    final double bottom = size.height -
        (padding.bottom +
            _bottomPadding +
            _captureButtonSize +
            _guidanceGap +
            _guidanceHeight);

    final double availableWidth = size.width - _framePadding * 2;
    final double availableHeight = bottom - top - _framePadding * 2;

    final double scale = math.min(
      1.0,
      math.min(
        availableWidth / _maxFrameWidth,
        availableHeight / _maxFrameHeight,
      ),
    );

    return Rect.fromCenter(
      center: Offset(size.width / 2, (top + bottom) / 2),
      width: _maxFrameWidth * scale,
      height: _maxFrameHeight * scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: AnimatedBuilder(
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
            body: LayoutBuilder(
              builder: (context, constraints) {
                final frameRect = _frameRect(
                  constraints.biggest,
                  MediaQuery.paddingOf(context),
                );

                return Stack(
                  children: [
                    // 1. Camera Preview with Tap Gesture
                    GestureDetector(
                      onTapDown: _onTapToFocus,
                      child: SizedBox.expand(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller
                                    .cameraController!.value.previewSize!.height,
                                height: controller
                                    .cameraController!.value.previewSize!.width,
                                child:
                                    CameraPreview(controller.cameraController!),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. Custom Pod Scanner Frame Overlay Mask
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(frameRect: frameRect),
                      ),
                    ),
                    if (_showFocusRing && _focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 25,
                        top: _focusPoint!.dy - 25,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2EFA8A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                    // 3. UI Navigation, guidance & Capture Action Bar
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
                          SizedBox(
                            height: _guidanceHeight,
                            child: _buildGuidance(),
                          ),
                          const SizedBox(height: _guidanceGap),
                          GestureDetector(
                            onTap: controller.isAnalyzing ? null : _onCapture,
                            child: Container(
                              height: _captureButtonSize,
                              width: _captureButtonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withAlpha(77),
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
                          const SizedBox(height: _bottomPadding),
                        ],
                      ),
                    ),

                    // 4. Analyzing Loading Screen Overlay
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuidance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D291A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF184D32),
                  width: 1.5,
                ),
              ),
              child: const Text(
                "CENTER POD INSIDE FRAME",
                style: TextStyle(
                  color: Color(0xFF2EFA8A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "↔ Distance: ~30cm | Tap screen to focus",
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ],
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
