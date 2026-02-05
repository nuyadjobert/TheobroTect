import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final bool showWeatherTip;
  final VoidCallback onTap;

  const WeatherCard({
    super.key,
    required this.showWeatherTip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isRainyExpected = true;
    String weatherCondition = "Showers Expected";
    const Color brandGreen = Color(0xFF2D6A4F);
    const Color darkGreen = Color(0xFF1B4332);
    const Color mintBg = Color(0xFFD8F3DC);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.3),
          border: Border.all(color: brandGreen.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isRainyExpected ? Icons.cloud_outlined : Icons.wb_sunny_outlined,
                      color: brandGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tagum City", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkGreen, letterSpacing: -0.3)),
                        Text(weatherCondition, style: TextStyle(color: brandGreen.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("26°C", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                    const SizedBox(width: 4),
                    Icon(showWeatherTip ? Icons.expand_less : Icons.expand_more, color: brandGreen, size: 18),
                  ],
                ),
              ],
            ),
            if (showWeatherTip) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: brandGreen.withOpacity(0.15), thickness: 1),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.tips_and_updates_outlined, color: Color(0xFFE5A500), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("FARMER'S ADVISORY", style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: brandGreen, letterSpacing: 0.6)),
                        const SizedBox(height: 1),
                        Text(
                          isRainyExpected ? "Rain expected soon. Avoid spraying to prevent wash-off." : "Clear skies. Perfect for harvesting or sun-drying beans.",
                          style: TextStyle(fontSize: 10, height: 1.3, fontWeight: FontWeight.w500, color: darkGreen.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}