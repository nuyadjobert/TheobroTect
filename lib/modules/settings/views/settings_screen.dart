import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/settings_tile.dart'; 
import '../widgets/help_center_screen.dart'; 
import '../widgets/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotifEnabled = true;

  @override
  Widget build(BuildContext context) {
    // 1. SYSTEM UI CONFIGURATION
    // This makes the status bar at the top visible and readable
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Makes the bar blend with your app color
        statusBarIconBrightness: Brightness.dark, // Dark icons (time/battery) for light BG (Android)
        statusBarBrightness: Brightness.light, // Dark icons for iOS
        systemNavigationBarColor: Colors.white, // Bottom nav bar color
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        // 2. APPBAR CONFIGURATION
        // We set the background to transparent to let the Scaffold color show through
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // Extra backup for visibility
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Settings",
            style: TextStyle(
              color: Color(0xFF1B3022), 
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Enhanced Profile Card
              _buildProfileCard(),
              
              const SizedBox(height: 32),
              _buildSectionLabel("GENERAL"),
              
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: "Notifications",
                onTap: () => setState(() => _isNotifEnabled = !_isNotifEnabled),
                trailing: Switch.adaptive(
                  value: _isNotifEnabled, 
                  onChanged: (v) => setState(() => _isNotifEnabled = v), 
                  activeColor: const Color(0xFF2D6A4F),
                ),
              ),
              
              const SettingsTile(
                icon: Icons.language_rounded,
                title: "App Language",
                subtitle: "English (US)",
              ),

              const SizedBox(height: 24),
              _buildSectionLabel("SUPPORT"),
              
              SettingsTile(
                icon: Icons.help_outline_rounded, 
                title: "Help Center",
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const HelpCenterScreen())
                ),
              ),
              
              SettingsTile(
                icon: Icons.info_outline_rounded, 
                title: "About TheobroTect",
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const AboutScreen())
                ),
              ),

              const SizedBox(height: 40),
              _buildLogoutButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- ENHANCED HELPER WIDGETS ---

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF1B3022)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFF9FBF9),
              child: Icon(Icons.person_rounded, color: Color(0xFF1B3022), size: 35),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Farmer John",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Davao Region, PH",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
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
          fontSize: 11, 
          fontWeight: FontWeight.w900, 
          color: Colors.grey, 
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: InkWell(
        onTap: () {
          // Add your Logout logic here
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "Logout Account",
                style: TextStyle(
                  color: Colors.redAccent, 
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}