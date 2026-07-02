import 'package:flutter/material.dart';

class GuideCard extends StatelessWidget {
  final String title;
  final String duration;
  final Color themeColor;
  final VoidCallback? onTap; // Navigation trigger
  final String? imageUrl; // Thumbnail (network URL or asset path)
  final String? rating; // e.g. "4.8"
  final String? enrollment; // e.g. "65"

  const GuideCard({
    super.key,
    required this.title,
    required this.duration,
    required this.themeColor,
    this.onTap,
    this.imageUrl,
    this.rating,
    this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(30), // 0.12 * 255 = 30
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(color: themeColor.withAlpha(30));
                          },
                          errorBuilder: (context, error, stack) =>
                              _fallbackBackground(),
                        )
                      else
                        _fallbackBackground(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.play_arrow_rounded,
                              color: themeColor, size: 20),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 11, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                duration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (rating != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              enrollment != null
                                  ? "$rating ($enrollment Enrolled)"
                                  : rating!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF1B3022),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withValues(alpha: 0.65),
            themeColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 40,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}