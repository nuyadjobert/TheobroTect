import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:cacao_apps/core/model/user.model.dart';

class NavFarmInfo extends StatelessWidget {
  const NavFarmInfo({super.key});

  @override
  Widget build(BuildContext context) {
        final UserRepository userRepository=UserRepository();

    return FutureBuilder<LocalUser?>(
      future: userRepository.getCurrentUser(),
      builder: (context, snapshot) {
        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Loading...", style: TextStyle(color: Colors.grey)),
          );
        }

        // ❌ Error state
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Error loading data", style: TextStyle(color: Colors.red)),
          );
        }

        // ✅ Data ready
        final user = snapshot.data;
        final String location = user?.address ?? "Sawata";

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FARM PROFILE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on_rounded, location),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2D6A4F)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1B3022)),
        ),
      ],
    );
  }
}