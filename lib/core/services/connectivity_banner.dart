import 'package:flutter/material.dart';

class ConnectivityBanner {
  static bool _isBannerVisible = false;

  static void showOfflineBanner(BuildContext context) {
    if (_isBannerVisible) return;
    _isBannerVisible = true;

    ScaffoldMessenger.of(context).showMaterialBanner(
     MaterialBanner(
  backgroundColor: const Color(0xFF1B3022),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  dividerColor: Colors.transparent,
  content: Row(
    children: [
      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
      const SizedBox(width: 8),
      const Expanded(
        child: Text(
          'No internet connection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      TextButton(
        onPressed: () => hideOfflineBanner(context),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Dismiss',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  ),
  actions: const [SizedBox.shrink()],
),
    );
  }

  static void hideOfflineBanner(BuildContext context) {
    if (!_isBannerVisible) return;
    _isBannerVisible = false;
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }

  static void showBackOnlineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Back online',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}