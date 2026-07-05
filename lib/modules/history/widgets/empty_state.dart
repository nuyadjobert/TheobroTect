import 'package:flutter/material.dart';

class FloatingGhost extends StatefulWidget {
  const FloatingGhost({super.key});

  @override
  State<FloatingGhost> createState() => _FloatingGhostState();
}

class _FloatingGhostState extends State<FloatingGhost>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          offset: Offset(0, _floatAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: const Text(
              "👻",
              style: TextStyle(fontSize: 64),
            ),
          ),
        );
      },
    );
  }
}