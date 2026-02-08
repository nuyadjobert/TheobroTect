import 'package:flutter/material.dart';
import '../widgets/scan_details.dart'; // Ensure this path matches your file structure

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Logic to determine theme based on status
    final String status = data['status'] ?? 'Healthy';
    final bool isInfected = status == 'Infected';
    final Color statusColor = isInfected ? const Color(0xFFE63946) : const Color(0xFF2D6A4F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Section
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'scan_${data['title']}_${data['date']}',
                    child: Image.asset(
                      data['image'] ?? 'assets/placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildStatusTag(status.toUpperCase(), statusColor),
                  ),
                ],
              ),
            ),

            // 2. Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Untitled Scan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: -0.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_outward, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          data['date'] ?? 'No date provided',
                          style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // 3. Confidence & View Details Trigger
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${data['confidence'] ?? 0}%",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ScanDetailsSheet.show(context, data), // OPEN MODAL
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              "View Details",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: statusColor.withOpacity(0.8),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}