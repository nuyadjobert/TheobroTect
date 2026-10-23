import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle appOverlayStyle(BuildContext context) {
  final theme = Theme.of(context);
  final iconBrightness =
      theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    systemNavigationBarColor: theme.colorScheme.surface,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}

InputDecoration appInputDecoration(
  BuildContext context, {
  required String hint,
  IconData? prefixIcon,
  String? errorText,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    errorText: errorText,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: colorScheme.primary),
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withAlpha(77),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: border(Colors.transparent, 0),
    enabledBorder: border(Colors.transparent, 0),
    focusedBorder: border(colorScheme.primary, 2),
    errorBorder: border(colorScheme.error, 1),
    focusedErrorBorder: border(colorScheme.error, 2),
  );
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withAlpha(180),
          disabledForegroundColor: colorScheme.onPrimary,
          elevation: isLoading ? 0 : 4,
          shadowColor: colorScheme.primary.withAlpha(100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Please wait...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  final bool large;

  const BrandHeader({super.key, this.large = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoSize = large ? 72.0 : 28.0;
    final fontSize = large ? 28.0 : 16.0;

    final wordmark = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
        children: [
          const TextSpan(
            text: 'Theobro',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          TextSpan(
            text: 'Tect',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );

    final logo = Image.asset(
      'assets/images/theobrotect.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
    );

    if (large) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [logo, const SizedBox(height: 8), wordmark],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(offset: const Offset(10, 0), child: logo),
        wordmark,
      ],
    );
  }
}

class BrandTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const BrandTopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
        ),
        const Spacer(),
        const BrandHeader(),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }
}
