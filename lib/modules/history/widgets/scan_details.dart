import 'package:flutter/material.dart';

class ScanDetailsSheet {
  static void show(BuildContext context, Map<String, dynamic> data) {
    final String status = data['status'] ?? 'Healthy';
    final String diseaseName = data['title'] ?? 'Cacao Leaf';
    final bool isInfected = status == 'Infected';
    final Color statusColor = isInfected ? const Color(0xFFE63946) : const Color(0xFF2D6A4F);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. MAIN IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1.6,
                        child: Image.asset(data['image'] ?? 'assets/placeholder.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. DIAGNOSTIC SUMMARY
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(isInfected ? Icons.bug_report : Icons.check_circle, color: statusColor, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isInfected ? "DISEASE DETECTED" : "PLANT HEALTH",
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                                ),
                                Text(
                                  isInfected ? diseaseName : "Healthy Leaf",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. SCAN INFO
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Scanned on: ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        Text(data['date'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                    // 4. ACTION STEPS
                    Text(
                      isInfected ? "Treatment Plan" : "Maintenance Routine",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStep(
                      icon: isInfected ? Icons.content_cut : Icons.water_drop,
                      title: isInfected ? "Prune Infected Areas" : "Proper Irrigation",
                      subtitle: isInfected ? "Remove and safely dispose of affected foliage." : "Water at the roots, avoiding the leaves.",
                      color: statusColor
                    ),
                    _buildStep(
                      icon: isInfected ? Icons.sanitizer : Icons.shield_outlined, // FIXED: lowercase 's'
                      title: isInfected ? "Apply Treatment" : "Regular Monitoring",
                      subtitle: isInfected ? "Use recommended organic fungicide." : "Check for early signs of spots weekly.",
                      color: statusColor
                    ),

                    const SizedBox(height: 32),

                    // 5. DISMISS BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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

  static Widget _buildStep({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}