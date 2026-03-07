import 'package:flutter/material.dart';
import '../widgets/mini_inspection_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
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

            _buildActionTile(
              context,
              title: "Schedule Treatment",
              icon: Icons.bar_chart_rounded,
              color: Colors.blue,
            ),
            _buildActionTile(
              context,
              title: "Schedule Treatment",
              icon: Icons.calendar_today_rounded,
              color: Colors.green,
            ),
            _buildActionTile(
              context,
              title: "Schedule Treatment",
              icon: Icons.check_circle_outline_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MiniInspectionTile(title: title),
    );
  }

  // Widget _buildImageError() {
  //   return Container(
  //     height: 220,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[100],
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
  //           const SizedBox(height: 8),
  //           Text("Preview unavailable", style: TextStyle(color: Colors.grey[500])),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
