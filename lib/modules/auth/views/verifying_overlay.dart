import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/widgets/app_components.dart';

class VerifyingOverlay extends StatefulWidget {
  const VerifyingOverlay({super.key});

  @override
  State<VerifyingOverlay> createState() => _VerifyingOverlayState();
}

class _VerifyingOverlayState extends State<VerifyingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _outerRingController;
  late final AnimationController _innerRingController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;
  late final AnimationController _fadeInController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _outerRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _innerRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: false);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _outerRingController.dispose();
    _innerRingController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final forestGreen = colorScheme.primary;
    final midGreen = colorScheme.primary;
    final lightGreen = colorScheme.secondary;
    final paleGreen = colorScheme.primary.withValues(alpha: 0.12);
    final accentGreen = colorScheme.secondary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Center(child: BrandHeader()),
              ),

              const Spacer(flex: 2),

              // ── Central animation ──
              AnimatedBuilder(
                animation: Listenable.merge([
                  _outerRingController,
                  _innerRingController,
                  _pulseController,
                  _particleController,
                ]),
                builder: (context, child) {
                  return SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outermost soft glow
                        Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentGreen.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Orbiting particles
                        ..._buildOrbitingParticles(colorScheme),

                        // Outer spinning ring (clockwise, fast)
                        Transform.rotate(
                          angle:
                              _outerRingController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(185, 185),
                            painter: _RingPainter(
                              color: forestGreen,
                              strokeWidth: 3.5,
                              segments: 4,
                              segmentSweep: 0.35,
                              gap: 1.22,
                            ),
                          ),
                        ),

                        // Inner spinning ring (counter-clockwise, slower)
                        Transform.rotate(
                          angle:
                              -_innerRingController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(155, 155),
                            painter: _RingPainter(
                              color: lightGreen.withValues(alpha: 0.6),
                              strokeWidth: 2,
                              segments: 6,
                              segmentSweep: 0.2,
                              gap: 0.85,
                            ),
                          ),
                        ),

                        // Background pale circle
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: paleGreen,
                            boxShadow: [
                              BoxShadow(
                                color: forestGreen.withValues(alpha: 0.12),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Pulsing white ring
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                color: accentGreen.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        // Inner circle
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                          ),
                        ),

                        // Green core with lock icon
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [lightGreen, midGreen],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: forestGreen.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            color: colorScheme.onPrimary,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 44),

              // ── Title ──
              Text(
                "Verifying Code...",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Please wait a moment",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 28),

              // ── Enhanced dot indicators ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WaveDot(delay: 0, color: forestGreen),
                  const SizedBox(width: 10),
                  _WaveDot(delay: 200, color: midGreen),
                  const SizedBox(width: 10),
                  _WaveDot(delay: 400, color: lightGreen),
                ],
              ),

              const Spacer(flex: 2),

              // ── Bottom secure badge ──
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: forestGreen.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: paleGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_user_rounded,
                            color: forestGreen, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Your data is 100% secure",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrbitingParticles(ColorScheme colorScheme) {
    const particleCount = 6;
    const orbitRadius = 100.0;

    return List.generate(particleCount, (i) {
      final angle = (i / particleCount) * 2 * math.pi +
          _particleController.value * 2 * math.pi;
      final x = math.cos(angle) * orbitRadius;
      final y = math.sin(angle) * orbitRadius;
      final opacity = (math.sin(
                  _particleController.value * 2 * math.pi + i * math.pi / 3) +
              1) /
          2;
      final size = 4.0 + (i % 2) * 2.0;

      return Positioned(
        left: 110 + x - size / 2,
        top: 110 + y - size / 2,
        child: Opacity(
          opacity: (opacity * 0.6).clamp(0.1, 0.6),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i % 2 == 0
                  ? colorScheme.primary
                  : colorScheme.secondary,
            ),
          ),
        ),
      );
    });
  }
}

// ── Multi-segment ring painter ──
class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int segments;
  final double segmentSweep;
  final double gap;

  const _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.segments,
    required this.segmentSweep,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < segments; i++) {
      final startAngle = i * (segmentSweep + gap);
      canvas.drawArc(rect, startAngle, segmentSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ── Wave-bouncing dot ──
class _WaveDot extends StatefulWidget {
  final int delay;
  final Color color;

  const _WaveDot({required this.delay, required this.color});

  @override
  State<_WaveDot> createState() => _WaveDotState();
}

class _WaveDotState extends State<_WaveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}