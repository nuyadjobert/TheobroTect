import 'package:flutter/material.dart';

class TotalScannedCard extends StatelessWidget {
  const TotalScannedCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF2D6A4F);
    const Color darkGreen = Color(0xFF1B4332);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: brandGreen.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: 38 / 45,
                      strokeWidth: 6,
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(brandGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const Icon(Icons.analytics_outlined, size: 20, color: darkGreen),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Farm Health Summary", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkGreen)),
                    Text("Based on your last 45 scans", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider(height: 1, thickness: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnhancedStatItem("45", "Total Scans", Colors.blueGrey),
              _buildEnhancedStatItem("38", "Healthy", brandGreen),
              _buildEnhancedStatItem("07", "Diseased", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Container(height: 3, width: 20, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.2)),
      ],
    );
  }
}