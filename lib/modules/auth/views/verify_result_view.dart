import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/toast.dart';

class VerifyResultView extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final List<Color> sparkleColors;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final VoidCallback? onBack;
  final String? errorToast;

  const VerifyResultView({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.sparkleColors,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.onBack,
    this.errorToast,
  });

  @override
  State<VerifyResultView> createState() => _VerifyResultViewState();
}

class _VerifyResultViewState extends State<VerifyResultView>
    with TickerProviderStateMixin {
  static const List<Offset> _sparklePositions = [
    Offset(-80, -60),
    Offset(80, -60),
    Offset(-90, 10),
    Offset(90, 10),
    Offset(-60, 70),
    Offset(60, 70),
    Offset(-20, -88),
    Offset(20, -88),
  ];
  static const List<double> _sparkleSizes = [
    12.0,
    10.0,
    8.0,
    12.0,
    10.0,
    8.0,
    10.0,
    8.0,
  ];

  late final AnimationController _scaleController;
  late final AnimationController _fadeController;
  late final AnimationController _sparkleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _sparkleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });

    final toast = widget.errorToast;
    if (toast != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) TopToast.show(context, toast, type: ToastType.error);
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onBack = widget.onBack;

    return AnnotatedRegion(
      value: appOverlayStyle(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: onBack == null
                    ? const Center(child: BrandHeader())
                    : BrandTopBar(onBack: onBack),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._buildSparkles(),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.35),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 72,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: AppPrimaryButton(
                    label: widget.buttonLabel,
                    onPressed: widget.onPressed,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your data is 100% secure',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(_sparklePositions.length, (index) {
      return AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          final delay = (index * 0.1).clamp(0.0, 1.0);
          final localProgress =
              ((_sparkleController.value - delay) / (1.0 - delay))
                  .clamp(0.0, 1.0);
          final size = _sparkleSizes[index];

          return Positioned(
            left: 110 + _sparklePositions[index].dx - size / 2,
            top: 110 + _sparklePositions[index].dy - size / 2,
            child: Opacity(
              opacity: localProgress,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.sparkleColors[
                            index % widget.sparkleColors.length]
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
