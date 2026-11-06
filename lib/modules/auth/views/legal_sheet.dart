import 'package:flutter/material.dart';
import '../../../core/widgets/app_components.dart';

class _LegalSection {
  final String heading;
  final String body;

  const _LegalSection(this.heading, this.body);
}

const List<_LegalSection> _termsSections = [
  _LegalSection(
    'Using TheobroTect',
    'TheobroTect helps you identify cacao diseases from photos and manage your farm records. Use it only for lawful, personal or farm-related purposes.',
  ),
  _LegalSection(
    'Scan results',
    'Results come from an AI model and are guidance only. They may not always be correct, so please confirm serious cases with an agricultural technician.',
  ),
  _LegalSection(
    'Your account',
    'Provide accurate information and keep your login secure. You are responsible for activity under your account.',
  ),
  _LegalSection(
    'Changes',
    'We may update the app and these terms from time to time. Continued use means you accept the updated terms.',
  ),
];

const List<_LegalSection> _privacySections = [
  _LegalSection(
    'What we collect',
    'Your name, email, barangay and contact number, plus the scan photos, results and locations you save in the app.',
  ),
  _LegalSection(
    'How we use it',
    'To create your account, give you disease results and recommendations, keep your scan history and sync it across your devices.',
  ),
  _LegalSection(
    'Sharing',
    'We do not sell your personal information. It is shared only when needed to run the service or when required by law.',
  ),
  _LegalSection(
    'Your choices',
    'You can update your profile in Settings at any time and contact us to ask about your data.',
  ),
];

Future<void> showTermsSheet(BuildContext context) =>
    _showLegalSheet(context, 'Terms of Service', _termsSections);

Future<void> showPrivacySheet(BuildContext context) =>
    _showLegalSheet(context, 'Privacy Policy', _privacySections);

Future<void> _showLegalSheet(
  BuildContext context,
  String title,
  List<_LegalSection> sections,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.8,
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colorScheme = theme.colorScheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in sections) ...[
                        Text(
                          section.heading,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: 'Got it',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
