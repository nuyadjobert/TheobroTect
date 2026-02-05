import 'package:flutter/material.dart';
import '../../screens/scanner_screen.dart';

class InspectionCard extends StatelessWidget {
  const InspectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD8F3DC), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.eco,
              size: 150,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.qr_code_scanner, color: Color(0xFF2D6A4F), size: 28),
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Scanner", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text("Check Your Pods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Detect diseases instantly using our AI camera.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF40916C)),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      shadowColor: const Color(0xFF2D6A4F).withOpacity(0.4),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Text("START SCANNING", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}