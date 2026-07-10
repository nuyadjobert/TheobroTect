import 'package:flutter/material.dart';

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(width: 140, height: 20, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 100, height: 14, color: Colors.white),

          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: List.generate(4, (index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E0E0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 14,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 20,
                            height: 20,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ],
                      ),
                    ),
                    if (index != 3)
                      Padding(
                        padding: const EdgeInsets.only(left: 68),
                        child: Container(
                          height: 0.6,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}