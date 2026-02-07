import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home_screen.dart'; // Adjust path based on your folder structure

class VerifyAccountScreen extends StatefulWidget {
  final String email;

  const VerifyAccountScreen({super.key, required this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}
class _VerifyAccountScreenState extends State<VerifyAccountScreen> {

  
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.energy_savings_leaf_rounded, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 8),
                    Text("TheobroTect",
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
                Text("Verify Identity",
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text("We've sent a 6-digit code to your email. Enter it below to proceed.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // 6-Digit OTP Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6, 
                    (index) => _buildOtpField(context, index == 0, colorScheme)
                  ),
                ),

                const SizedBox(height: 48),
                
                Center(
                  child: Column(
                    children: [
                      Text("RESEND CODE IN 00:59", 
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.outline,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                        child: const Text("Didn't get a code?", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      shadowColor: colorScheme.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      // Navigate to Home and clear the navigation stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "VERIFY", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text("BACK TO SIGN IN", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: colorScheme.outline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(BuildContext context, bool first, ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: first ? colorScheme.primary : colorScheme.outlineVariant,
          width: first ? 2 : 1,
        ),
        boxShadow: [
          if (first) BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        autofocus: first,
        onChanged: (value) {
          if (value.length == 1) FocusScope.of(context).nextFocus();
          if (value.isEmpty) FocusScope.of(context).previousFocus();
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
      ),
    );
  }
}