import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import '../../home/views/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final RegistrationController controller;
  final RegistrationRequest model;

  const RegistrationScreen({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Using a deep Forest Green palette
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightForest = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 40),
                
                // Branding Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightForest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded, // TheobroTect / Cocoa theme icon
                      color: forestGreen,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Text(
                  "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: forestGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the TheobroTect community and protect your crops today.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                _buildInputField(
                  label: "Full Name",
                  controller: widget.controller.nameController,
                  hint: "John Doe",
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 20),

                _buildInputField(
                  label: "Address",
                  controller: widget.controller.addressController,
                  hint: "City, Province",
                  icon: Icons.map_outlined,
                ),

                const SizedBox(height: 20),

                _buildInputField(
                  label: "Contact Number",
                  controller: widget.controller.phoneController,
                  hint: "0912 345 6789",
                  icon: Icons.phone_android_rounded,
                  isNumber: true,
                ),

                const SizedBox(height: 24),
                _buildTermsText(),
                const SizedBox(height: 32),

                // Register Button
                _buildRegisterButton(context),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          ),
        ),
        const Text(
          "TheobroTect",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: forestGreen,
          ),
        ),
        const SizedBox(width: 40), // Balance
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: forestGreen),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: forestGreen.withOpacity(0.7)),
            filled: true,
            fillColor: lightForest.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: forestGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final bool isLoading = widget.controller.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: forestGreen.withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text(
                "Complete Registration",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    await widget.controller.submitRegistration(
      email: widget.model.email,
    );

    if (!mounted) return;

    if (widget.controller.isRegistrationSuccessful) {
      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Welcome! Account created successfully."),
            ],
          ),
          backgroundColor: forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Delay slightly so user sees the success message
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      // ERROR MESSAGE
      final msg = widget.controller.errorMessage ?? "Registration failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
    setState(() {});
  }

  Widget _buildTermsText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
        children: [
          const TextSpan(text: "By clicking Register, you agree to our "),
          TextSpan(
            text: "Terms",
            style: const TextStyle(color: forestGreen, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(color: forestGreen, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
        ],
      ),
    );
  }
}