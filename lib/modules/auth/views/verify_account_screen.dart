import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/views/home_screen.dart';
import '../services/auth_services.dart';
import '../../../core/network/client.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;

  const VerifyAccountScreen({super.key, required this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  late final AuthService _service;
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = AuthService(DioClient.dio);
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpCtrls.map((c) => c.text).join();

  Future<void> _verify() async {
    final otp = _otp.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _service.verifyOtp(email: widget.email, otp: otp);

      if (!mounted) return;

      if (result.status == 'OK') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
        return;
      }

      final msg = switch (result.status) {
        'INVALID_OTP' => 'Invalid code. Please try again.',
        'OTP_EXPIRED' => 'Code expired. Please request a new one.',
        'NO_ACTIVE_OTP' => 'No active code. Request a new OTP.',
        'PENDING_APPROVAL' => 'Your account is pending approval.',
        'ACCOUNT_DELETED' => 'This account was deleted.',
        'NEW_USER_REQUIRED' => 'No account found. Please register.',
        _ => 'Verification failed: ${result.status}',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
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
                Row(
                  children: [
                    Icon(
                      Icons.energy_savings_leaf_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "TheobroTect",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  "Verify Identity",
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => _buildOtpField(context, i, colorScheme),
                  ),
                ),

                const SizedBox(height: 48),

                Center(
                  child: Column(
                    children: [
                      Text(
                        "RESEND CODE IN 00:59",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.outline,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        child: const Text(
                          "Didn't get a code?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 8,
                      shadowColor: colorScheme.primary.withAlpha(
                        (0.4 * 255).toInt(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _verify,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 3),
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
    final isFirst = index == 0;
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst ? colorScheme.primary : colorScheme.outlineVariant,
          width: isFirst ? 2 : 1,
        ),
        boxShadow: [
          if (isFirst)
            BoxShadow(
              color: colorScheme.primary.withAlpha((0.1 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: _otpCtrls[index],
        autofocus: isFirst,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0)
            FocusScope.of(context).previousFocus();
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
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
