import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/help_center_screen.dart';
import '../widgets/about_screen.dart';
import '../widgets/photo_search.dart';
import 'package:cacao_apps/modules/auth/login_factory.dart';
import '../controllers/settings_controller.dart';
import '../../../theme/theme_controller.dart';
import '../../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _prefsKey = 'profile_photo_path';
  static const _storedFileName = 'profile_photo.jpg';

  bool _isNotifEnabled = true;
  final SettingsController _controller = SettingsController();
  final ImagePicker _picker = ImagePicker();

  // Persisted profile photo. Loaded from SharedPreferences in initState and
  // written back to disk + prefs every time it changes.
  File? _profileImage;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadPersistedImage();
  }

  Future<void> _loadPersistedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPath = prefs.getString(_prefsKey);
    if (storedPath != null && await File(storedPath).exists()) {
      if (!mounted) return;
      setState(() {
        _profileImage = File(storedPath);
        _loadingImage = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _loadingImage = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return; // user cancelled

      // Copy out of the OS's temp/cache location into a stable spot inside
      // the app's own documents directory, so it isn't cleared by the OS
      // and survives app restarts.
      final docsDir = await getApplicationDocumentsDirectory();
      final savedPath = '${docsDir.path}/$_storedFileName';
      final targetFile = File(savedPath);

      
      await FileImage(targetFile).evict();

      final savedFile = await File(picked.path).copy(savedPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, savedFile.path);

      if (!mounted) return;
      setState(() => _profileImage = savedFile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't open ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e")),
      );
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPath = prefs.getString(_prefsKey);
    if (storedPath != null) {
      final file = File(storedPath);
      // Same cache-eviction reasoning as in _pickImage: clear the stale
      // entry for this path so a future re-add doesn't show leftover bytes.
      await FileImage(file).evict();
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove(_prefsKey);
    if (!mounted) return;
    setState(() => _profileImage = null);
  }

  Future<void> _handlePhotoTap() async {
    final action = await showPhotoSourceSheet(
      context,
      hasExistingPhoto: _profileImage != null,
    );
    if (action == null) return; // dismissed without choosing

    switch (action) {
      case PhotoSourceAction.camera:
        await _pickImage(ImageSource.camera);
        break;
      case PhotoSourceAction.gallery:
        await _pickImage(ImageSource.gallery);
        break;
      case PhotoSourceAction.remove:
        await _removeImage();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = isDark ? AppColors.nightBg : AppColors.creamBg;
    final Color cardBg = isDark ? AppColors.nightCard : AppColors.creamCard;
    final Color textPrimary = isDark ? Colors.white : AppColors.forestDark;
    final Color textSecondary = isDark ? Colors.white60 : Colors.grey;
    final Color divider = isDark ? AppColors.nightDivider : Colors.grey.shade200;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Settings",
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              _buildProfileHeader(textPrimary, textSecondary, bg),
              const SizedBox(height: 32),
              _buildSettingsCard(cardBg, textPrimary, textSecondary, divider, isDark),
              const SizedBox(height: 28),
              _buildLogoutRow(cardBg, textPrimary, textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // --- PROFILE HEADER ---

  Widget _buildProfileHeader(Color textPrimary, Color textSecondary, Color bg) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.forestMid, width: 2),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.forestMid.withAlpha(38),
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.person_rounded, color: textPrimary.withAlpha(180), size: 46)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _handlePhotoTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.forestMid,
                    shape: BoxShape.circle,
                    border: Border.all(color: bg, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Farmer John",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          "Davao Region, PH",
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // --- SETTINGS CARD ---

  Widget _buildSettingsCard(
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color divider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildRow(
            icon: Icons.notifications_active_outlined,
            title: "Notifications",
            textPrimary: textPrimary,
            onTap: () => setState(() => _isNotifEnabled = !_isNotifEnabled),
            trailing: Switch.adaptive(
              value: _isNotifEnabled,
              onChanged: (v) => setState(() => _isNotifEnabled = v),
              activeThumbColor: AppColors.forestMid,
              activeTrackColor: AppColors.forestMid,
            ),
          ),
          _buildDivider(divider),
          // Real dark mode toggle — drives ThemeController, which the
          // whole app listens to via MaterialApp (see main.dart wiring).
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.instance.mode,
            builder: (context, mode, _) {
              final isDarkNow = mode == ThemeMode.dark;
              return _buildRow(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                textPrimary: textPrimary,
                onTap: () => ThemeController.instance.setDarkMode(!isDarkNow),
                trailing: Switch.adaptive(
                  value: isDarkNow,
                  onChanged: (v) => ThemeController.instance.setDarkMode(v),
                  activeThumbColor: AppColors.forestMid,
                  activeTrackColor: AppColors.forestMid,
                ),
              );
            },
          ),
          _buildDivider(divider),
          _buildRow(
            icon: Icons.help_outline_rounded,
            title: "Help Center",
            textPrimary: textPrimary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
          ),
          _buildDivider(divider),
          _buildRow(
            icon: Icons.info_outline_rounded,
            title: "About TheobroTect",
            textPrimary: textPrimary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, thickness: 0.6, color: color),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required Color textPrimary,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.forestMid.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.forestMid, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // --- LOGOUT ROW ---

  Widget _buildLogoutRow(Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
              content: Text(
                "Are you sure you want to logout?",
                style: TextStyle(color: textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Cancel", style: TextStyle(color: textSecondary)),
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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 19),
              SizedBox(width: 14),
              Text(
                "Logout Account",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}