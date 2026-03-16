import 'dart:async';
import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/verify_account_controller.dart';
import '../services/auth_services.dart';
import '../../../core/network/client.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import 'registration_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;

  const VerifyAccountScreen({super.key, required this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color lightForest = Color(0xFFE8F5E9);

  late final VerifyAccountController controller;

  @override
  void initState() {
    super.initState();
    controller = VerifyAccountController(
      auth: AuthService(DioClient.dio),
      email: widget.email,
    );
    controller.requestOtp();
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
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
Center(
  child: Row(
    mainAxisSize: MainAxisSize.min, // Shrinks the Row to only fit its content
    children: [
      // The Icon
      Transform.translate(
        offset: const Offset(15, 0), // Moves icon 15px closer/into the text
        child: Image.asset(
          'assets/images/theobrotect.png',
          width: 60, // Adjusted size to fit better inline
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
      // The Text
      const Text(
        "TheobroTect",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: forestGreen,
          letterSpacing: -0.5,
        ),
      ),
    ],
  ),
),

                const SizedBox(height: 50),

                Center(
                  child: Text(
                    "Verify Identity",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: forestGreen,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We've sent a 6-digit code to your email. Enter it below to proceed.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 48),

                // --- OTP INPUT SECTION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => _buildOtpField(context, i, colorScheme),
                  ),
                ),

                const SizedBox(height: 48),

                // --- RESEND SECTION ---
                Center(
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: controller,
                        builder: (_, __) {
                          return Text(
                            "RESEND CODE IN ${controller.timerText}",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: controller.secondsLeft > 0
                                  ? colorScheme.outline
                                  : forestGreen,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: controller,
                        builder: (_, _) {
                          return TextButton(
                            onPressed: controller.secondsLeft == 0
                                ? () {
                                    controller.startTimer(200);
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor: forestGreen,
                            ),
                            child: Text(
                              controller.secondsLeft == 0
                                  ? "Resend New Code"
                                  : "Didn't get a code?",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- VERIFY BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen, // Applied forestGreen
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: forestGreen.withAlpha(102), // 0.4 * 255
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            await controller.verify();
                            if (!mounted) return;

                            if (controller.isVerified ||
                                controller.isNewUserRequired) {
                              // UPDATED SNACKBAR: Forest Green & Floating
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.verified_user_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text("Verification Successful!"),
                                    ],
                                  ),
                                  backgroundColor:
                                      forestGreen, // Set to forestGreen
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }

                            if (controller.isNewUserRequired) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => RegistrationScreen(
                                    controller: RegistrationController(
                                      AuthService(DioClient.dio),
                                    ),
                                    model: RegistrationRequest(
                                      email: controller.email,
                                      fullName: '',
                                      address: '',
                                      contactNumber: '',
                                    ),
                                  ),
                                ),
                              );
                            } else if (controller.isVerified) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              final msg = controller.errorMessage;
                              if (msg != null && msg.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "VERIFY",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- BACK BUTTON ---
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text(
                      "BACK TO SIGN IN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(
    BuildContext context,
    int index,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: lightForest.withOpacity(0.3), // Matches login/register theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: forestGreen.withOpacity(0.1), width: 1),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        autofocus: index == 0,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0)
            FocusScope.of(context).previousFocus();
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: forestGreen,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }
}
