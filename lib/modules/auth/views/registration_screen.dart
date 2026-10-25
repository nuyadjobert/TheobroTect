import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/toast.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import '../../home/views/home_screen.dart';
import 'verify_success_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final RegistrationController controller;
  final RegistrationRequest model;

  const RegistrationScreen({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final RegistrationController controller;
  late final RegistrationRequest model;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    model = widget.model;
  }

  Future<void> _handleRegister() async {
    await controller.submitRegistration(
      email: model.email,
      name: controller.nameController.text.trim(),
      address: controller.addressController.text.trim(),
      contactNumber: controller.phoneController.text.trim(),
    );

    if (!mounted) return;

    if (controller.isRegistrationSuccessful) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (successContext) => VerifySuccessScreen(
            title: 'Account Created!',
            message: 'Welcome to TheobroTect.\nYour account is ready to use.',
            onContinue: () => Navigator.of(successContext).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ),
        (route) => false,
      );
      return;
    }

    final msg = controller.errorMessage;
    if (msg != null && msg.isNotEmpty) {
      TopToast.show(context, msg, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion(
      value: appOverlayStyle(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  BrandTopBar(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 24),
                  Text(
                    "Create Account",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join the TheobroTect community and protect your crops today.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Full Name", theme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.nameController,
                    keyboardType: TextInputType.name,
                    decoration: appInputDecoration(
                      context,
                      hint: "Enter your full name",
                      prefixIcon: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Address", theme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.addressController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: appInputDecoration(
                      context,
                      hint: "Enter your full address",
                      prefixIcon: Icons.location_on,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Contact Number", theme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: appInputDecoration(
                      context,
                      hint: "Enter your contact number",
                      prefixIcon: Icons.phone,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "By clicking Register, you agree to our "),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: "\nand "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: "Register",
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading: controller.isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
