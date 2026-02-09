import 'package:flutter/material.dart';
import '../widgets/alert_badge.dart';
import '../widgets/mini_inspection_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3), // Slightly softer green-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Subtle shadow for depth
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Alert Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Alert Card with Shadow
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const AlertBadge(), 
                  const SizedBox(height: 16),
                  
                  // Image with Inner Padding for a "Framed" Look
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/img1.png',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImageError(),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          "Time to rescan Tree #4",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              "Last scanned 5 days ago",
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Section Header
            const Row(
              children: [
                Icon(Icons.bolt, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  "Recommended Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Enhanced Tiles
            _buildActionTile(
              context, 
              title: "Schedule Treatment", 
              icon: Icons.bar_chart_rounded, 
              color: Colors.blue
            ),
            _buildActionTile(
              context, 
              title: "Schedule Treatment", 
              icon: Icons.calendar_today_rounded, 
              color: Colors.green
            ),
            _buildActionTile(
              context, 
              title: "Schedule Treatment", 
              icon: Icons.check_circle_outline_rounded, 
              color: Colors.grey
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent action tiles
  Widget _buildActionTile(BuildContext context, {required String title, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MiniInspectionTile(
        title: title,
        // If your MiniInspectionTile supports icons/colors, pass them here
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("Preview unavailable", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}