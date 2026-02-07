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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withAlpha((0.3 * 255).toInt()),
          border: Border.all(
            color: brandGreen.withAlpha((0.15 * 255).toInt()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).toInt()),
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
                    if (isRainyExpected)
                      const Icon(
                        Icons.cloud_outlined,
                        color: brandGreen,
                        size: 18,
                      ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tagum City",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: darkGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          weatherCondition,
                          style: TextStyle(
                            color: brandGreen.withAlpha((0.7 * 255).toInt()),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "26°C",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showWeatherTip ? Icons.expand_less : Icons.expand_more,
                      color: brandGreen,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            if (showWeatherTip) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  color: brandGreen.withAlpha((0.15 * 255).toInt()),
                  thickness: 1,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_outlined,
                      color: Color(0xFFE5A500),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "FARMER'S ADVISORY",
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: brandGreen,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 1),
                        if (isRainyExpected)
                          Text(
                            "Rain expected soon. Avoid spraying to prevent wash-off.",
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              color: darkGreen.withAlpha((0.8 * 255).toInt()),
                            ),
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
