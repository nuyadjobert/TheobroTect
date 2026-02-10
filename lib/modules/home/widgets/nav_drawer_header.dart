import 'package:flutter/material.dart';

class NavDrawerHeader extends StatelessWidget {
  const NavDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2D6A4F),
        image: DecorationImage(
          image: AssetImage('assets/images/pattern_bg.png'), // Add a subtle leaf pattern if you have one
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Color(0xFF2D6A4F)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                "Farmer John",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(Icons.verified, color: Colors.blue[300], size: 18),
            ],
          ),
          const Text(
            "john.cacao@farm.com",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}