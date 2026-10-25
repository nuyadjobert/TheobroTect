import 'package:flutter/material.dart';
import '../../../core/widgets/app_components.dart';
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

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    return AnnotatedRegion(
      value: appOverlayStyle(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = isKeyboardOpen ? 0.0 : constraints.maxHeight * 0.27;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Center(child: BrandHeader(large: true)),

                          // ── Cacao farm image — fades on all edges, hides on keyboard ──
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            height: imageHeight,
                            width: double.infinity,
                            child: isKeyboardOpen
                                ? const SizedBox.shrink()
                                : ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white,
                                          Colors.white,
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.15, 0.75, 1.0],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) {
                                        return const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white,
                                            Colors.white,
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.08, 0.92, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: Image.asset(
                                        'assets/images/cacao_farm.png',
                                        width: double.infinity,
                                        height: imageHeight,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                          ),

                          const Spacer(),

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

                          const SizedBox(height: 24),

                          Text(
                            "Email Address",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (v) {
                              if (model.emailError != null) {
                                setState(() => model.emailError = null);
                              }
                            },
                            decoration: appInputDecoration(
                              context,
                              hint: "name@example.com",
                              prefixIcon: Icons.email,
                              errorText: model.emailError,
                            ),
                          ),

                          const Spacer(),

                          AppPrimaryButton(
                            label: "Continue",
                            trailingIcon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleContinue,
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
        ),
      ),
    );
  }
}
