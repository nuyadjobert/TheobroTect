import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';
import 'verify_account_screen.dart'; 

class LoginScreen extends StatefulWidget {
  final LoginController controller;
  final LoginModel model;

  const LoginScreen({super.key, required this.controller, required this.model});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LOGO SECTION
                Center(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -40,
                        right: -110,
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 350,
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Column(
                        children: [
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
                                    color: forestGreen,
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

                // 2. WELCOME TEXT
                Text(
                  "Welcome Back",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
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

                // 3. EMAIL INPUT
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold, color: forestGreen),
                  ),
                ),
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
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
                      color: forestGreen,
                    ),
                    filled: true,
                    fillColor: lightForest.withOpacity(0.3),
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

                // 4. ACTION BUTTON WITH NAVIGATION
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
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
                            // Hides keyboard to prevent UI overflow
                            FocusScope.of(context).unfocus();

                            // Trigger the logic in the controller
                            await controller.onContinue(context, () => setState(() {}));

                            // If validation passes, navigate to the verification screen
                            if (model.emailError == null && controller.emailController.text.isNotEmpty) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.mark_email_read_rounded, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "OTP sent to ${controller.emailController.text}",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: forestGreen,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );

                              // Navigate to VerifyAccountScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyAccountScreen(
                                    email: controller.emailController.text,
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