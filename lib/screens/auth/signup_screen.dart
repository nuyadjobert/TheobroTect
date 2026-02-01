import 'package:flutter/material.dart';
import '../../widgets/auth_textfield.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Register to start managing your cacao farm",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              AuthTextField(
                label: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: "Confirm Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Signup logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account created successfully")),
                    );
                  },
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
