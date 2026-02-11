import 'package:flutter/material.dart';

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(width: 100, height: 25, color: Colors.white), // Title
          const SizedBox(height: 30),
          // Profile Card
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          const SizedBox(height: 40),
          // Settings List Items
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(width: 150, height: 15, color: Colors.white),
                  const Spacer(),
                  Container(width: 30, height: 15, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}