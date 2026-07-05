import 'dart:ui' as ui;
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

  // Adjusted dimensions to match the cacao pod aspect ratio in your design
  static const double _frameWidth = 280;
  static const double _frameHeight = 440;

  @override
  void initState() {
    super.initState();

    controller = ScannerController();
    controller.init();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

 Future<void> _onCapture() async {
  final results = await controller.captureAndAnalyze();

  if (!mounted || results == null || results.isEmpty) return;

  // Sort by confidence (IMPORTANT for UI clarity)
  results.sort((a, b) => b.confidence.compareTo(a.confidence));

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ScanResultScreen(
        results: results, // ✅ pass full list
      ),
    ),
  );
}

// // Inside your Camera Screen UI...
// Future<void> _onCapture() async {
//   // 1. Call your ScannerController (using the exact variable name 'controller')
//   final results = await controller.captureAndAnalyze();

//   if (results != null && results.isNotEmpty) {
    
//     // Optional: Sort by confidence to guarantee the highest score is always primary
//     results.sort((a, b) => b.confidence.compareTo(a.confidence));

//     // 2. Safely grab the primary disease (Index 0)
//     final primary = results[0];
    
//     // 3. Safely check if a secondary disease exists (Index 1)
//     final hasSecondary = results.length > 1;

//     // 4. Navigate to the Result Screen
//     if (!mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ScanResultScreen(
//           // --- PRIMARY ---
//           imagePath: primary.imagePath,
//           diseaseName: primary.diseaseName,
//           confidence: primary.confidence,
//           severity: primary.severity,
          
//           // --- SECONDARY (No string quotes!) ---
//           secondaryDiseaseName: hasSecondary ? results[1].diseaseName : null,
//           secondaryConfidence: hasSecondary ? results[1].confidence : null,
//           secondarySeverity: hasSecondary ? results[1].severity : null,
//         ),
//       ),
//     );
//   }
// }

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
              // 1. Camera Preview — full screen (Unchanged Size/Logic)
              ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller
                          .cameraController!.value.previewSize!.height,
                      height:
                          controller.cameraController!.value.previewSize!.width,
                      child: CameraPreview(controller.cameraController!),
                    ),
                  ),
                ),
              ),

              // 2. Custom Pod Scanner Overlay (Mask, Dashes, Corners, Crosshair)
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(
                    frameWidth: _frameWidth,
                    frameHeight: _frameHeight,
                  ),
                ),
              ),

              // 3. Frame size label & instructions
              Positioned(
                top: MediaQuery.of(context).size.height / 2 +
                    _frameHeight / 2 +
                    24, // Spaced neatly below the frame
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D291A), // Dark green background
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF184D32), // Subtle green border
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        "FIT THE CACAO POD INSIDE",
                        style: TextStyle(
                          color: Color(0xFF2EFA8A), // Vibrant green text
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "↔ Keep distance: ~30cm",
                      style: TextStyle(
                        color: Colors.white.withAlpha(179), // 70% opacity
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. UI Controls (top bar + capture button)
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
                    GestureDetector(
                      onTap: controller.isAnalyzing ? null : _onCapture,
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(77), // 30% opacity
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

              // 5. Analyzing overlay
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
                          color: Colors.white.withAlpha(179), // 70% opacity
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

/// Custom painter to draw the dark mask, dashed pod outline, crosshairs, and corner brackets
class ScannerOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  ScannerOverlayPainter({
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double podRadius = 80.0; // The roundedness of the pod cutout

    // 1. Draw Semi-Transparent Dark Mask
    final bgPaint = Paint()..color = Colors.black.withAlpha(204); // 80% opacity
    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final cutoutRect = Rect.fromCenter(
        center: Offset(cx, cy), width: frameWidth, height: frameHeight);
    final cutoutRRect = RRect.fromRectAndRadius(cutoutRect, Radius.circular(podRadius));
    final cutoutPath = Path()..addRRect(cutoutRRect);

    // Subtract the pod shape from the dark background
    final overlayPath =
        Path.combine(PathOperation.difference, bgPath, cutoutPath);
    canvas.drawPath(overlayPath, bgPaint);

    // 2. Draw Inner Dashed Border
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(102) // 40% opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPath = Path()..addRRect(cutoutRRect);
    for (ui.PathMetric measurePath in dashPath.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < measurePath.length) {
        double length = draw ? 8.0 : 6.0; // 8px dash, 6px gap
        canvas.drawPath(
          measurePath.extractPath(distance, distance + length),
          dashPaint,
        );
        distance += length;
        draw = !draw;
      }
    }

    // 3. Draw Center Crosshair
    final crosshairPaint = Paint()
      ..color = Colors.white.withAlpha(77) // 30% opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    const double crosshairSize = 24.0;
    canvas.drawLine(Offset(cx - crosshairSize / 2, cy),
        Offset(cx + crosshairSize / 2, cy), crosshairPaint);
    canvas.drawLine(Offset(cx, cy - crosshairSize / 2),
        Offset(cx, cy + crosshairSize / 2), crosshairPaint);

    // 4. Draw Neon Green Corner Brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF2EFA8A) // Match the neon green from the design
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double margin = 12.0; // Distance of the corners from the inner dashed line
    final double cornerRadius = podRadius + (margin / 2); // Expanding curve logically
    final double cornerLength = 30.0;

    final double left = cx - (frameWidth / 2) - margin;
    final double right = cx + (frameWidth / 2) + margin;
    final double top = cy - (frameHeight / 2) - margin;
    final double bottom = cy + (frameHeight / 2) + margin;

    // Top-Left Corner
    Path tl = Path()
      ..moveTo(left, top + cornerRadius + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(Offset(left + cornerRadius, top),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(left + cornerRadius + cornerLength, top);
    canvas.drawPath(tl, cornerPaint);

    // Top-Right Corner
    Path tr = Path()
      ..moveTo(right - cornerRadius - cornerLength, top)
      ..lineTo(right - cornerRadius, top)
      ..arcToPoint(Offset(right, top + cornerRadius),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(right, top + cornerRadius + cornerLength);
    canvas.drawPath(tr, cornerPaint);

    // Bottom-Right Corner
    Path br = Path()
      ..moveTo(right, bottom - cornerRadius - cornerLength)
      ..lineTo(right, bottom - cornerRadius)
      ..arcToPoint(Offset(right - cornerRadius, bottom),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(right - cornerRadius - cornerLength, bottom);
    canvas.drawPath(br, cornerPaint);

    // Bottom-Left Corner
    Path bl = Path()
      ..moveTo(left + cornerRadius + cornerLength, bottom)
      ..lineTo(left + cornerRadius, bottom)
      ..arcToPoint(Offset(left, bottom - cornerRadius),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(left, bottom - cornerRadius - cornerLength);
    canvas.drawPath(bl, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}