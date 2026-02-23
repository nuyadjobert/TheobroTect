import 'package:flutter/material.dart';

class MovableFeedbackMenu extends StatefulWidget {
  const MovableFeedbackMenu({super.key});

  @override
  State<MovableFeedbackMenu> createState() => _MovableFeedbackMenuState();
}

class _MovableFeedbackMenuState extends State<MovableFeedbackMenu> {
  Offset position = const Offset(-1, -1);
  bool isMenuOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize to the bottom right corner
    if (position.dx == -1) {
      final size = MediaQuery.of(context).size;
      position = Offset(size.width - 80, size.height - 250);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Draggable(
                    feedback: Material(
                      type: MaterialType.transparency,
                      child: _buildMainButton(isDragging: true),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragEnd: (details) {
                      setState(() {
                        double x = details.offset.dx;
                        double y = details.offset.dy;

                        // Strict boundary checks to keep button on screen
                        if (x < 10) x = 10;
                        if (x > size.width - 70) x = size.width - 70;
                        if (y < 50) y = 50;
                        if (y > size.height - 150) y = size.height - 150;

                        position = Offset(x, y);
                      });
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: Stack(
                        alignment: Alignment.centerRight, // Button stays right, menu grows left
                        clipBehavior: Clip.none,
                        children: [
                          _buildInwardMenu(),
                          GestureDetector(
                            onTap: () => setState(() => isMenuOpen = !isMenuOpen),
                            child: _buildMainButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInwardMenu() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      // The crucial fix: margin-right pushes the menu away from the right edge
      margin: const EdgeInsets.only(right: 35), 
      width: isMenuOpen ? 200 : 0,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          if (isMenuOpen)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(-5, 5),
            )
        ],
      ),
      child: isMenuOpen 
        ? ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuOption(Icons.support_agent_rounded, "Help Center"),
                  _buildDivider(),
                  _buildMenuOption(Icons.email_outlined, "Email Us"),
                  _buildDivider(),
                  _buildMenuOption(Icons.star_rate_rounded, "Rate App"),
                ],
              ),
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildMenuOption(IconData icon, String label) {
    return InkWell(
      onTap: () => setState(() => isMenuOpen = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2D6A4F)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey[200], indent: 15, endIndent: 15);

  Widget _buildMainButton({bool isDragging = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2D6A4F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: isDragging ? 15 : 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Icon(
          isMenuOpen ? Icons.close_rounded : Icons.support_agent_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}