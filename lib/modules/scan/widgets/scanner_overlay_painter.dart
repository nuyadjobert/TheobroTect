import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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