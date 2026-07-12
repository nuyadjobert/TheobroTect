import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class TopToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);

    Color backgroundColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        break;

      case ToastType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;

      case ToastType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;

      case ToastType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TopToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopToastWidget({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}


class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Timer(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}