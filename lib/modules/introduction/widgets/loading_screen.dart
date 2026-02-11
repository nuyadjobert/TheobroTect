import 'package:flutter/material.dart';
import 'dart:math' as math;
class TheobroTectLoader extends StatefulWidget {
  const TheobroTectLoader({super.key});

  @override
  State<TheobroTectLoader> createState() => _TheobroTectLoaderState();
}

class _TheobroTectLoaderState extends State<TheobroTectLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(); // Continues the circular reveal

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Center(
    child: SizedBox(
      height: 600, // Increased to accommodate bigger text
      width: 600,  // Increased to accommodate bigger text
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. THE CIRCLE FRAME (1.png)
          Positioned(
            left: -13, 
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (rect) {
                    return SweepGradient(
                      startAngle: -1.5708,
                      endAngle: 4.7124,
                      stops: [_animation.value, _animation.value],
                      colors: [Colors.white, Colors.transparent],
                    ).createShader(rect);
                  },
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/1.png',
                width: 430,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. THE BRAND NAME (3.png) - UPDATED: Bigger and Left-Aligned
          Positioned(
            left: -70, // Moves the text to the left
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double pulse = 1.0 + (math.sin(_animation.value * 2 * math.pi) * 0.03);
                return Transform.scale(
                  scale: pulse,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/3.png',
                width: 460, // INCREASED size from 500 to 580
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 3. THE SMALL LEAF (2.png)
          Positioned(
            top: 150, // Adjusted top slightly to maintain balance with larger text
            child: ScaleTransition(
              scale: _animation, 
              child: Image.asset(
                'assets/images/2.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}