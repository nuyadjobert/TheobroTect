import 'package:flutter/material.dart';
import '../../widgets/auth_textfield.dart';
import 'signup_screen.dart';
import '../../navigation_menu.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo or App Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco, size: 80, color: primaryGreen),
                ),
              ),
              const SizedBox(height: 40),
              Text("Welcome Back", 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryGreen)),
              const Text("Sign in to your Cacao account", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              
              const AuthTextField(label: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 16),
              const AuthTextField(label: "Password", icon: Icons.lock_outline, isPassword: true),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Use pushAndRemoveUntil to clear the navigation stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const NavigationMenu()),
                      (route) => false,
                    );
                  },
                  child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New farmer?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                    child: const Text("Create Account"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}