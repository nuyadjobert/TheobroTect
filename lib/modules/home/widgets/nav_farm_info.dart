import 'package:flutter/material.dart';

class NavFarmInfo extends StatelessWidget {
  const NavFarmInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FARM PROFILE", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_rounded, "Davao City, PH"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.landscape_rounded, "4.5 Hectares"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.agriculture_rounded, "Trinitario Cacao"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2D6A4F)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF1B3022))),
      ],
    );
  }
}