import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// What the user picked in [showPhotoSourceSheet].
enum PhotoSourceAction { camera, gallery, remove }

Future<PhotoSourceAction?> showPhotoSourceSheet(
  BuildContext context, {
  bool hasExistingPhoto = false,
}) {
  return showModalBottomSheet<PhotoSourceAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => PhotoSourceSheet(hasExistingPhoto: hasExistingPhoto),
  );
}

class PhotoSourceSheet extends StatelessWidget {
  final bool hasExistingPhoto;

  const PhotoSourceSheet({super.key, this.hasExistingPhoto = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.nightCard : AppColors.creamCard;
    final textPrimary = isDark ? Colors.white : AppColors.forestDark;
    final textSecondary = isDark ? Colors.white60 : Colors.grey;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: textSecondary.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Update Profile Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
              ),
            ),
            _buildOption(
              context: context,
              icon: Icons.camera_alt_rounded,
              label: "Take Photo",
              textColor: textPrimary,
              action: PhotoSourceAction.camera,
            ),
            _buildOption(
              context: context,
              icon: Icons.photo_library_rounded,
              label: "Choose from Gallery",
              textColor: textPrimary,
              action: PhotoSourceAction.gallery,
            ),
            if (hasExistingPhoto)
              _buildOption(
                context: context,
                icon: Icons.delete_outline_rounded,
                label: "Remove Photo",
                textColor: Colors.redAccent,
                action: PhotoSourceAction.remove,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color textColor,
    required PhotoSourceAction action,
  }) {
    final isDestructive = action == PhotoSourceAction.remove;
    return InkWell(
      onTap: () => Navigator.pop(context, action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : AppColors.forestMid, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}