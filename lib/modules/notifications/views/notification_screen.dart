import 'package:flutter/material.dart';
import '../../scan/views/scanner_screen.dart'; // Ensure this path is correct
import '../widgets/mini_inspection_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          style: TextStyle(
            color: Color(0xFF1B4332), 
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D6A4F).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Recent Detection",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Cacao Pod Borer Detected",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Identified in Sector B • 2 hours ago",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  "Recommended Actions",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildActionTile(context, title: "Apply Organic Pesticide"),
            _buildActionTile(context, title: "Schedule Farm Visit"),
            _buildActionTile(context, title: "Mark Area as Treated"),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MiniInspectionTile(
        title: title,
        onScanTap: () {
          // DIRECT NAVIGATION TO SCANNER
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
      ),
    );
  }
}