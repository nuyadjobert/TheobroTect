import 'package:flutter/material.dart';
import '../widgets/scan_details.dart'; 
import 'dart:io'; 

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Added to handle deletion

  const HistoryCard({
    super.key, 
    required this.data, 
    required this.onTap, 
    required this.onDelete, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    final String status = data['status'] ?? 'Healthy';
    final bool isInfected = status == 'Infected';
    final Color statusColor = isInfected ? const Color(0xFFE63946) : const Color(0xFF2D6A4F);

    final bool isLocalFile = data['isLocalFile'] ?? false;
    final String? imagePath = data['image'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: statusColor.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'scan_${data['title']}_${data['date']}',
                    child: (isLocalFile && imagePath != null)
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            imagePath ?? 'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black.withAlpha(77), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // STATUS TAG
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildStatusTag(status.toUpperCase(), statusColor),
                  ),
                  // --- DELETE BUTTON (Kept in your specified location) ---
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onDelete, // Logic now connected
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline, 
                          color: Colors.white, 
                          size: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TEXT CONTENT SECTION (Exactly as you provided)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Untitled Scan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: -0.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_outward, size: 12, color: Colors.grey[400]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['date'] ?? 'No date',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${data['confidence'] ?? 0}%",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () => ScanDetailsSheet.show(context, data),
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              "Details",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: statusColor.withAlpha(204),
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}