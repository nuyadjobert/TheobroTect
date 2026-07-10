import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/profile_controller.dart';
import '../../../core/widgets/toast.dart';
import '../../../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  late final UserProfileController controller;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    controller = UserProfileController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _loadUser() async {
    await controller.loadUser();

    final user = controller.user;

    if (user != null) {
      _nameController.text = user.name ?? "";
      _emailController.text = user.email;
      _contactController.text = user.contactNumber;
      _addressController.text = user.address;
    }

    setState(() {});
  }

  Future<void> _saveChanges() async {
    final currentUser = controller.user;
    if (currentUser == null) return;

    setState(() {
      _isSaving = true;
    });

    // Let the user know a save is underway.
    TopToast.show(context, "Saving changes...");

    try {
      await controller.updateProfile(
        name: _nameController.text.trim() != (currentUser.name ?? "")
            ? _nameController.text.trim()
            : null,
        address: _addressController.text.trim() != (currentUser.address)
            ? _addressController.text.trim()
            : null,
        contactNumber:
            _contactController.text.trim() != (currentUser.contactNumber)
                ? _contactController.text.trim()
                : null,
      );

      if (!mounted) return;
      TopToast.show(context, "Profile updated successfully!");

      setState(() {
        _isEditing = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theming aligned with the Settings screen's palette.
    final Color bg = isDark ? AppColors.nightBg : AppColors.creamBg;
    final Color appBarBg = isDark ? AppColors.nightBg : Colors.white;
    final Color cardBg = isDark ? AppColors.nightCard : AppColors.creamCard;
    final Color textPrimary = isDark ? Colors.white : AppColors.forestDark;
    final Color textSecondary = isDark ? Colors.white60 : Colors.grey;
    final Color accentColor =
        isDark ? AppColors.forestLight : AppColors.forestMid;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
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
          iconTheme: IconThemeData(color: textPrimary),
          title: Text(
            "My Profile",
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Indicator
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: accentColor.withAlpha(26),
                  child: Icon(Icons.person_rounded,
                      color: textPrimary.withAlpha(128), size: 54),
                ),
              ),
              const SizedBox(height: 32),

              // Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark ? Colors.black26 : Colors.black.withAlpha(128),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.badge_outlined,
                      isEditable: _isEditing,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: accentColor,
                      showEditToggle: true,
                    ),
                    const SizedBox(height: 20),

                    // Email is ALWAYS read-only
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      isEditable: false,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: accentColor,
                      isLocked: true,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _contactController,
                      label: "Contact Number",
                      icon: Icons.phone_outlined,
                      isEditable: _isEditing,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: accentColor,
                      keyboardType: TextInputType.phone,
                      showEditToggle: true,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _addressController,
                      label: "Address",
                      icon: Icons.location_on_outlined,
                      isEditable: _isEditing,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: accentColor,
                      maxLines: 2,
                      showEditToggle: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Animated Save Button (Only shows when editing)
              AnimatedOpacity(
                opacity: _isEditing ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _isEditing
                    ? SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            child: _isSaving
                                ? const Row(
                                    key: ValueKey("saving"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Saving...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Save Changes",
                                    key: ValueKey("idle"),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditable,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    bool isLocked = false,
    bool showEditToggle = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final textColor = (isEditable) ? textPrimary : textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: true,
          readOnly: !isEditable,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                color: isEditable ? accentColor : textSecondary.withAlpha(128),
                size: 22),
            suffixIcon: isLocked
                ? Icon(Icons.lock_outline_rounded,
                    color: textSecondary.withAlpha(128), size: 18)
                : showEditToggle
                    ? IconButton(
                        onPressed: _toggleEditMode,
                        icon: Icon(
                          isEditable
                              ? Icons.close_rounded
                              : Icons.edit_rounded,
                          color:
                              isEditable ? Colors.redAccent : accentColor,
                          size: 18,
                        ),
                      )
                    : null,
            filled: true,
            fillColor:
                isEditable ? Colors.transparent : textSecondary.withAlpha(128),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: textSecondary.withAlpha(51), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}