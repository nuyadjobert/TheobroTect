import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cacao_apps/modules/auth/login_factory.dart';
import '../controllers/settings_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../core/model/user.model.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/settings_section_label.dart';
import '../widgets/account_settings.dart';
import '../widgets/support_settings.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _controller = SettingsController();
  final HistoryController _historyController = HistoryController();
  LocalUser? currentUser;

  File? _profileImage;

  int _overallScans = 0;
  String _farmStatus = "Loading...";
  int _diseasesScanned = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFarmStats();
  }

  Future<void> _loadUser() async {
    currentUser = await _controller.getCurrentUser();
    setState(() {});
  }

  Future<void> _loadFarmStats() async {
    final stats = await _historyController.getFarmStats();
    if (!mounted) return;
    setState(() {
      _overallScans = stats['overallScans'];
      _farmStatus = stats['farmStatus'];
      _diseasesScanned = stats['diseasesScanned'];
    });
  }

  // --- NAVIGATION ---
  // Push Profile, then refresh the user once we're back — otherwise the
  // hero card keeps showing stale data until this screen is torn down
  // and rebuilt from scratch (e.g. by switching bottom-nav tabs).
  Future<void> _navigateToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfileScreen()),
    );
    if (!mounted) return;
    _loadUser();
  }

  // --- LOGOUT ---
  // Business logic only. The confirmation dialog itself lives in
  // LogoutButton; this is what runs once the user has confirmed.
  Future<void> _handleLogoutConfirmed() async {
    await _controller.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => buildLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = isDark ? AppColors.nightBg : AppColors.creamBg;
    final Color appBarBg = isDark ? AppColors.nightBg : Colors.white;
    final Color cardBg = isDark ? AppColors.nightCard : AppColors.creamCard;
    final Color textPrimary = isDark ? Colors.white : AppColors.forestDark;
    final Color textSecondary = isDark ? Colors.white60 : Colors.grey;
    final Color textMuted = isDark ? Colors.white38 : Colors.grey[500]!;
    final Color divider =
        isDark ? AppColors.nightDivider : Colors.grey.shade200;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Dark icons on light app bar, light icons on dark app bar
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: appBarBg,
          systemOverlayStyle:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
        body: Column(
          children: [
            // --- PINNED SECTION: profile hero card + stats row ---
            // This stays fixed in place; it does NOT scroll with the list below.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  ProfileHeroCard(
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    currentUser: currentUser,
                    profileImage: _profileImage,
                  ),
                  const SizedBox(height: 12),
                  StatsRow(
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    overallScans: _overallScans,
                    farmStatus: _farmStatus,
                    diseasesScanned: _diseasesScanned,
                  ),
                ],
              ),
            ),

            // --- SCROLLABLE SECTION: Account, Support, Logout ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // Extra bottom padding (120) clears the parent HomeScreen's
                // BottomAppBar, since HomeScreen uses extendBody: true and
                // this screen's content would otherwise be obscured by it.
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SettingsSectionLabel(label: "Account", textMuted: textMuted),
                    const SizedBox(height: 8),
                    AccountSettingsCard(
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: divider,
                      onProfileTap: _navigateToProfile,
                    ),
                    const SizedBox(height: 24),
                    SettingsSectionLabel(label: "Support", textMuted: textMuted),
                    const SizedBox(height: 8),
                    SupportSettingsCard(
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: divider,
                    ),
                    const SizedBox(height: 24),
                    LogoutButton(
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onConfirmed: _handleLogoutConfirmed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}