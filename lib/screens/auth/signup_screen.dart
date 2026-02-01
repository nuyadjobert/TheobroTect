import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/auth_textfield.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consistent color palette with Login/Onboarding
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1B3022);
    const Color backgroundWhite = Color(0xFFFBFDFB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundWhite,
        // Using a clean AppBar for the back button
        appBar: AppBar(
          backgroundColor: backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // Header Section
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the community of digital cacao farmers.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Form Fields
                const AuthTextField(
                  label: "Full Name",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 18),

                const AuthTextField(
                  label: "Email Address",
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 18),

                const AuthTextField(
                  label: "Password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 18),

                const AuthTextField(
                  label: "Confirm Password",
                  icon: Icons.shield_outlined,
                  isPassword: true,
                ),
                
                const SizedBox(height: 40),

                // Main Action Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Success Feedback
                      HapticFeedback.lightImpact(); // Pro touch: Add haptics
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Account created successfully"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Text(
                      "Create My Account",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: darkText),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}