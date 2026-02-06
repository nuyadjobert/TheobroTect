import 'package:flutter/material.dart';
import '../widgets/settings/settings_tile.dart';
import 'package:flutter/services.dart'; // Add this import
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Makes status bar blend with AppBar
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.light, // For iOS (dark icons)
  ));
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Premium Profile Card
            _buildProfileCard(),
            
            const SizedBox(height: 32),
            _buildSectionLabel("GENERAL"),
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: "Notifications",
              trailing: Switch.adaptive(
                value: true, 
                onChanged: (v) {}, 
                activeColor: const Color(0xFF2D6A4F),
              ),
            ),
            const SettingsTile(
              icon: Icons.language_rounded,
              title: "App Language",
              subtitle: "English (US)",
            ),

            const SizedBox(height: 24),
            _buildSectionLabel("SECURITY"),
            const SettingsTile(icon: Icons.lock_person_outlined, title: "Change Password"),
            const SettingsTile(icon: Icons.fingerprint_rounded, title: "Biometric Login"),

            const SizedBox(height: 24),
            _buildSectionLabel("SUPPORT"),
            const SettingsTile(icon: Icons.help_outline_rounded, title: "Help Center"),
            const SettingsTile(icon: Icons.info_outline_rounded, title: "About TheobroTect"),

            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2D6A4F), const Color(0xFF1B3022)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Farmer John",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Davao Region, PH",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_suggest_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w900, 
          color: Colors.grey, 
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        label: const Text(
          "Logout Account",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}