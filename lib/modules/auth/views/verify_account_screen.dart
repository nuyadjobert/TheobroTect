import 'package:cacao_apps/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/verify_account_controller.dart';
import '../services/auth_services.dart';
import '../../../core/network/client.dart';
import '../../../core/widgets/app_components.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import 'registration_screen.dart';
import 'verifying_overlay.dart';
import 'verify_unsuccess_screen.dart';
import 'verify_success_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;
  final int? initialSeconds;

  const VerifyAccountScreen({
    super.key,
    required this.email,
    this.initialSeconds,
  });

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  late final VerifyAccountController controller;
  bool _registrationPushed = false;

  @override
  void initState() {
    super.initState();
    controller = VerifyAccountController(
      auth: AuthService(DioClient.dio),
      email: widget.email,
    );
    final initialSeconds = widget.initialSeconds;
    if (initialSeconds != null) {
      controller.startTimer(initialSeconds);
    } else {
      controller.requestOtp();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openRegistration() {
    if (_registrationPushed) return;
    _registrationPushed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(
            controller: RegistrationController(AuthService(DioClient.dio)),
            model: RegistrationRequest(
              email: controller.email,
              name: '',
              address: '',
              contactNumber: '',
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight < 700 ? 180.0 : 220.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appOverlayStyle(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: true,
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.verificationStatus == VerificationStatus.verifying) {
              return const VerifyingOverlay();
            }

            if (controller.verificationStatus == VerificationStatus.success) {
              return VerifySuccessScreen(
                onContinue: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              );
            }

            if (controller.isNewUserRequired) {
              _openRegistration();
              return const SizedBox.shrink();
            }

            if (controller.verificationStatus == VerificationStatus.failed) {
              return VerifyUnsuccessScreen(
                message: controller.verificationMessage,
                onTryAgain: controller.resetVerification,
              );
            }

            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              BrandTopBar(
                                onBack: () => Navigator.pop(context),
                              ),

                              const Spacer(),

                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/images/verify_illustration.png',
                                    width: double.infinity,
                                    height: imageHeight,
                                    fit: BoxFit.fitHeight,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            SizedBox(
                                      height: imageHeight,
                                      child: Icon(
                                        Icons.verified_user_outlined,
                                        size: 80,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(),

                              Text(
                                "Verify Identity",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "We've sent a 6-digit code to your email. Enter it below to proceed.",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (i) =>
                                      _buildOtpField(context, i, colorScheme),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "RESEND CODE IN ${controller.timerText}",
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: controller.secondsLeft > 0
                                            ? colorScheme.outline
                                            : colorScheme.primary,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: controller.secondsLeft == 0
                                          ? controller.requestOtp
                                          : null,
                                      style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                      ),
                                      child: Text(
                                        controller.secondsLeft == 0
                                            ? "Resend New Code"
                                            : "Didn't get a code?",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              AppPrimaryButton(
                                label: "Verify",
                                onPressed: controller.verify,
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
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
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withAlpha(25), width: 1),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        autofocus: index == 0,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
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
