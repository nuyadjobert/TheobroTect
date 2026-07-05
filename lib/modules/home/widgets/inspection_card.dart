import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../scan/views/scanner_screen.dart';

class InspectionCard extends StatelessWidget {
  const InspectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1B3022), Color(0xFF16241A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFD8F3DC), Color(0xFFF1F8E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final decorIconColor = isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(128);
    final iconCircleBg = isDark ? AppColors.nightCard : Colors.white;
    final scannerIconColor = isDark ? AppColors.forestLight : const Color(0xFF2D6A4F);
    final eyebrowColor = isDark ? Colors.white60 : Colors.grey;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B4332);
    final bodyColor = isDark ? const Color(0xFF95D5B2) : const Color(0xFF40916C);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withAlpha(isDark ? 60 : 25),
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
              color: decorIconColor,
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
                      decoration: BoxDecoration(color: iconCircleBg, shape: BoxShape.circle),
                      child: Icon(Icons.qr_code_scanner, color: scannerIconColor, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Scanner",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: eyebrowColor),
                        ),
                        Text(
                          "Check Your Pods",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Detect diseases instantly using our AI camera.",
                  style: TextStyle(fontSize: 14, color: bodyColor),
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
                      shadowColor: const Color(0xFF2D6A4F).withAlpha(102),
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