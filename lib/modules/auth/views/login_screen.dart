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

    const Color primaryGreen = Color(0xFF2E7D32);
    const Color surfaceColor = Color(0xFFFBFDFB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
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
                    clipBehavior: Clip.none, 
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            "assets/images/theobrotect.png",
                            width: 78,
                            height: 78,
                          ),
                        ),
                      ),
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
                                    color: colorScheme.primary,
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
                    color: colorScheme.onSurface,
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

                Text(
                  "Email Address",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailController,
                  onChanged: (v) {
                    if (model.emailError != null) {
                      setState(() => model.emailError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "pedrokalungsod2@gmail.com",
                    errorText: model.emailError,
                    // prefixIcon: Icon(
                    //   Icons.alternate_email_rounded,
                    //   color: colorScheme.primary,
                    // ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(
                      (0.3 * 255).toInt(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
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
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () =>
                        controller.onContinue(context, () => setState(() {})),
                    child: const Text(
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
