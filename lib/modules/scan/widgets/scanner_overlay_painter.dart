import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Rect frameRect;

  ScannerOverlayPainter({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = frameRect.center.dx;
    final double cy = frameRect.center.dy;
    final double frameWidth = frameRect.width;
    final double frameHeight = frameRect.height;
    final double podRadius = frameRect.shortestSide * 0.2857;

    final bgPaint = Paint()..color = Colors.black.withAlpha(204);
    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutRRect = RRect.fromRectAndRadius(frameRect, Radius.circular(podRadius));
    final cutoutPath = Path()..addRRect(cutoutRRect);

    final overlayPath =
        Path.combine(PathOperation.difference, bgPath, cutoutPath);
    canvas.drawPath(overlayPath, bgPaint);

    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPath = Path()..addRRect(cutoutRRect);
    for (ui.PathMetric measurePath in dashPath.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < measurePath.length) {
        double length = draw ? 8.0 : 6.0;
        canvas.drawPath(
          measurePath.extractPath(distance, distance + length),
          dashPaint,
        );
        distance += length;
        draw = !draw;
      }
    }

    final crosshairPaint = Paint()
      ..color = Colors.white.withAlpha(77)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double crosshairSize = 24.0;
    canvas.drawLine(Offset(cx - crosshairSize / 2, cy),
        Offset(cx + crosshairSize / 2, cy), crosshairPaint);
    canvas.drawLine(Offset(cx, cy - crosshairSize / 2),
        Offset(cx, cy + crosshairSize / 2), crosshairPaint);

    final cornerPaint = Paint()
      ..color = const Color(0xFF2EFA8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double margin = 12.0;
    final double cornerRadius = podRadius + (margin / 2);
    final double cornerLength = 30.0;

    final double left = cx - (frameWidth / 2) - margin;
    final double right = cx + (frameWidth / 2) + margin;
    final double top = cy - (frameHeight / 2) - margin;
    final double bottom = cy + (frameHeight / 2) + margin;

    Path tl = Path()
      ..moveTo(left, top + cornerRadius + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(Offset(left + cornerRadius, top),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(left + cornerRadius + cornerLength, top);
    canvas.drawPath(tl, cornerPaint);

    Path tr = Path()
      ..moveTo(right - cornerRadius - cornerLength, top)
      ..lineTo(right - cornerRadius, top)
      ..arcToPoint(Offset(right, top + cornerRadius),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(right, top + cornerRadius + cornerLength);
    canvas.drawPath(tr, cornerPaint);

    Path br = Path()
      ..moveTo(right, bottom - cornerRadius - cornerLength)
      ..lineTo(right, bottom - cornerRadius)
      ..arcToPoint(Offset(right - cornerRadius, bottom),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(right - cornerRadius - cornerLength, bottom);
    canvas.drawPath(br, cornerPaint);

    Path bl = Path()
      ..moveTo(left + cornerRadius + cornerLength, bottom)
      ..lineTo(left + cornerRadius, bottom)
      ..arcToPoint(Offset(left, bottom - cornerRadius),
          radius: Radius.circular(cornerRadius), clockwise: true)
      ..lineTo(left, bottom - cornerRadius - cornerLength);
    canvas.drawPath(bl, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.frameRect != frameRect;
}
