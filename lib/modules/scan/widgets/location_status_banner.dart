import 'package:flutter/material.dart';
import 'package:cacao_apps/modules/scan/controllers/location_picker_controller.dart';

class LocationStatusBanner extends StatelessWidget {
  final LocationPickerController locationPicker;
  final VoidCallback onTap;
  final bool isDisabled;

  const LocationStatusBanner({
    super.key,
    required this.locationPicker,
    required this.onTap,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locationPicker,
      builder: (context, _) {
        if (isDisabled) {
          return const _BannerTile(
            icon: Icons.block,
            color: Colors.grey,
            message: "Location not required for non-cacao scan",
          );
        }

        final lp = locationPicker;

        if (lp.isLoading) {
          return const _BannerTile(
            icon: Icons.gps_not_fixed,
            color: Colors.orange,
            message: "Detecting your location...",
            trailing: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            ),
          );
        }

        if (lp.needsManualPick) {
          return GestureDetector(
            onTap: onTap,
            child: _BannerTile(
              icon: Icons.location_off,
              color: Colors.red.shade600,
              message: lp.accuracy != null
                  ? "Low GPS accuracy (±${lp.accuracy!.toStringAsFixed(0)}m) — tap to pin"
                  : "No GPS signal — tap to pin your location",
              trailing: Icon(Icons.chevron_right, color: Colors.red.shade600, size: 20),
            ),
          );
        }

        if (lp.isManuallyPicked) {
          return GestureDetector(
            onTap: onTap,
            child: const _BannerTile(
              icon: Icons.location_on,
              color: Color(0xFF2D6A4F),
              message: "Location pinned manually — tap to adjust",
              trailing: Icon(Icons.edit_location_alt_outlined, color: Color(0xFF2D6A4F), size: 18),
            ),
          );
        }

        final acc = lp.accuracy;
        return GestureDetector(
          onTap: onTap,
          child: _BannerTile(
            icon: Icons.gps_fixed,
            color: const Color(0xFF2D6A4F),
            message: acc != null
                ? "Location detected (±${acc.toStringAsFixed(0)}m) — tap to adjust"
                : "Location detected — tap to adjust",
            trailing: const Icon(Icons.edit_location_alt_outlined, color: Color(0xFF2D6A4F), size: 18),
          ),
        );
      },
    );
  }
}

class _BannerTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final Widget? trailing;

  const _BannerTile({
    required this.icon,
    required this.color,
    required this.message,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}