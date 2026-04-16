import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/settings_tile.dart';
import '../widgets/help_center_screen.dart';
import '../widgets/about_screen.dart';
import 'package:cacao_apps/modules/auth/login_factory.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotifEnabled = true;
  final SettingsController _controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        // Returning to a single scrollable area
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // Added significant bottom padding (100) to ensure the logout button 
          // can be scrolled well above the bottom of the screen
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                  activeThumbColor: const Color(0xFF2D6A4F),
                  activeTrackColor: const Color(0xFF2D6A4F),
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
                  MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: "About TheobroTect",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                ),
              ),
              
              // Spacing before the button
              const SizedBox(height: 60),
              
              // Button is now part of the scrollable list
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

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
            color: const Color(0xFF2D6A4F).withAlpha(77),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (confirm != true) return;

            await _controller.logout();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => buildLoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          label: const Text(
            "Logout Account",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.redAccent.withOpacity(0.05),
          ),
        ),
      ),
    );
  }
}