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

  bool _isLoading = false;

  // 2. Add the handler method
  Future<void> _handleContinue() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await controller.onContinue(context, () => setState(() {}));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? primaryGreen.withAlpha(180)
                          : primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: _isLoading ? 0 : 4,
                      shadowColor: primaryGreen.withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleContinue,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: _isLoading
                          ? const Row(
                              key: ValueKey('loading'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Please wait...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              key: ValueKey('idle'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
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
