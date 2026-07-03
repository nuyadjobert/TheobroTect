import 'package:flutter/material.dart';

class PreventionTipCard extends StatelessWidget {
  final String label;
  final String message;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback? onTap;
  final String characterAsset;

  const PreventionTipCard({
    super.key,
    this.label = "TODAY'S ACTION",
    this.message =
        "Sterilize your pruning tools before moving between trees.",
    this.icon = Icons.sanitizer_rounded,
    this.buttonLabel = "Got it",
    this.onTap,
    this.characterAsset = "assets/images/img_overlap.png",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
     
      padding: const EdgeInsets.only(top: 34),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 128, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D6A4F), Color(0xFF4A7C59)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D6A4F).withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: const Color(0xFF2D6A4F), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          buttonLabel,
                          style: const TextStyle(
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -30,
            right: -26,
            child: SizedBox(
              width: 210,
              height: 156,
              child: Image.asset(
                characterAsset,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}