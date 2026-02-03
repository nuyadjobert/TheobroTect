import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'verify_account_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
=======
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color surfaceColor = Color(0xFFFBFDFB);

>>>>>>> Stashed changes
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
<<<<<<< Updated upstream
=======
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
>>>>>>> Stashed changes
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
<<<<<<< Updated upstream
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
=======
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
>>>>>>> Stashed changes
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
<<<<<<< Updated upstream
                        child: Icon(Icons.energy_savings_leaf_rounded, 
                             size: 56, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 32, letterSpacing: -1, color: colorScheme.onSurface),
                          children: [
                            const TextSpan(text: "Theobro", style: TextStyle(fontWeight: FontWeight.w300)),
                            TextSpan(text: "Tect", style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary)),
                          ],
                        ),
                      ),
                    ],
=======
                      ],
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 50,
                      color: primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B3022),
                    letterSpacing: -1,
>>>>>>> Stashed changes
                  ),
                ),
                const SizedBox(height: 60),
                Text("Welcome Back", 
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text("Enter your credentials to manage your cacao farm.", 
                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 48),
                
                // Enhanced TextField
                Text("Email Address", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: "farmer@theobrotect.com",
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
<<<<<<< Updated upstream
                const SizedBox(height: 40),
=======

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
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Primary Action Button
>>>>>>> Stashed changes
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
<<<<<<< Updated upstream
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerifyAccountScreen()),
=======
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NavigationMenu(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Login to Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
>>>>>>> Stashed changes
                    ),
                    child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
<<<<<<< Updated upstream
=======

                const SizedBox(height: 24),

                // 5. Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New farmer?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryGreen,
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
>>>>>>> Stashed changes
              ],
            ),
          ),
        ),
      ),
    );
  }
}
