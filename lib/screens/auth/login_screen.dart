import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/auth_textfield.dart';
import 'signup_screen.dart';
import '../../navigation_menu.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pro Tip: Defining your semantic colors here keeps the build method clean
    final Color primaryGreen = const Color(0xFF2E7D32); // A rich, accessible Forest Green
    final Color surfaceColor = const Color(0xFFFBFDFB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons for light background
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            // Use BouncingScrollPhysics for a more premium "iOS-like" feel on all platforms
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                
                // 1. Refined Logo Section
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(Icons.eco_rounded, size: 50, color: primaryGreen),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 2. Bold Header
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B3022),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue your harvest monitoring",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    letterSpacing: 0.2,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 3. Input Fields
                const AuthTextField(
                  label: "Email Address", 
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 20),
                const AuthTextField(
                  label: "Password", 
                  icon: Icons.lock_outline_rounded, 
                  isPassword: true,
                ),
                
                // Forgot Password - Pushed to the right
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: primaryGreen),
                    child: const Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 4. Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0, // Flat design is more modern
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const NavigationMenu()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Login to Account",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 5. Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New farmer?", style: TextStyle(color: Colors.grey[700])),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const SignupScreen())
                      ),
                      style: TextButton.styleFrom(foregroundColor: primaryGreen),
                      child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
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