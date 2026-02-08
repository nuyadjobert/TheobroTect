import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';

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
  late final RegistrationController controller;
  late final RegistrationRequest model;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const Color primaryGreen = Color(0xFF2E7D32);
    const Color inputBorderColor = Color(0xFF4CAF50);
    const Color surfaceColor = Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        "TheobroTect",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 30),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.energy_savings_leaf,
                    color: primaryGreen,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the TheobroTect community and protect your crops today.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                _buildLabel("Full Name", theme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.nameController,
                  hint: "Enter your full name",
                  icon: Icons.person,
                  primaryColor: inputBorderColor,
                ),

                const SizedBox(height: 20),

                _buildLabel("Address", theme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.addressController,
                  hint: "Enter your full address",
                  icon: Icons.location_on,
                  primaryColor: inputBorderColor,
                ),

                const SizedBox(height: 20),

                _buildLabel("Contact Number", theme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.phoneController,
                  hint: "Enter your contact number",
                  icon: Icons.phone,
                  primaryColor: inputBorderColor,
                  isNumber: true,
                ),

                const SizedBox(height: 24),

                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    children: [
                      const TextSpan(
                        text: "By clicking Register, you agree to our ",
                      ),
                      TextSpan(
                        text: "Terms of Service",
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: "\nand "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB925),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            await controller.submitRegistration(
                              email: model
                                  .email, 
                            );

                            if (!mounted) return;
                            setState(() {});
                            if (controller.isRegistrationSuccessful) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/dashboard');
                              return;
                            }
                            final msg = controller.errorMessage;
                            if (msg != null && msg.isNotEmpty) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          },
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor.withAlpha(128), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
