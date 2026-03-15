import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';

class LoginScreen extends StatefulWidget {
  final LoginController controller;
  final LoginModel model;

  const LoginScreen({super.key, required this.controller, required this.model});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Using the consistent Forest Green palette
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color lightForest = Color(0xFFE8F5E9);
  static const Color surfaceColor = Color(0xFFFBFDFB);

  late final LoginController controller;
  late final LoginModel model;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    model = widget.model;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        // FIX: Prevents yellow/black pixel overflow when keyboard appears
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO SECTION USING STACK
                Center(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none, // Allows the logo to "float"
                    children: [
                      // This is the actual large logo
                      Positioned(
                        top: -40, // Adjust this to move the logo up or down
                        right: -110,
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 350, // Your requested large size
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // This Column controls the "Actual" space taken and the branding text
                      Column(
                        children: [
                          // We only "reserve" 180px of height, even though the logo is 330px
                          const SizedBox(height: 180), 
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                letterSpacing: -1,
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Theobro",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                TextSpan(
                                  text: "Tect",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: forestGreen, // Updated to forestGreen
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 2. Welcome Text
                Text(
                  "Welcome Back",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: forestGreen, // Updated to forestGreen
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your credentials to manage your cacao farm.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 3. Email Input
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold, color: forestGreen),
                  ),
                ),
                TextField(
                  controller: controller.emailController,
                  onChanged: (v) {
                    if (model.emailError != null) {
                      setState(() => model.emailError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "farmer@gmail.com",
                    errorText: model.emailError,
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      color: forestGreen, // Updated to forestGreen
                    ),
                    filled: true,
                    fillColor: lightForest.withOpacity(0.3), // Matches Registration Screen
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: forestGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Action Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen, // Updated to forestGreen
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: forestGreen.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: model.isLoading 
                      ? null 
                      : () async {
                          // Call the controller logic
                          await controller.onContinue(context, () => setState(() {}));

                          // Only show the message if validation passed and it's not empty
                          if (model.emailError == null && controller.emailController.text.isNotEmpty) {
                            if (!mounted) return;
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.mark_email_read_rounded, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Text("OTP sent to ${controller.emailController.text}"),
                                  ],
                                ),
                                backgroundColor: forestGreen, // Updated to forestGreen
                                behavior: SnackBarBehavior.floating, // FIX: Floating avoids yellow pixel overflow
                                margin: const EdgeInsets.all(20), // Padding for floating snackbar
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                    child: model.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
}