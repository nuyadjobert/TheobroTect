import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/location_picker_controller.dart';

class LocationPickerSheet extends StatefulWidget {
  final LocationPickerController controller;
  final LatLng? initialPosition;

  const LocationPickerSheet({
    super.key,
    required this.controller,
    this.initialPosition,
  });

  static Future<bool> show(
    BuildContext context, {
    required LocationPickerController controller,
    LatLng? initialPosition,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        controller: controller,
        initialPosition: initialPosition,
      ),
    );
    return result ?? false;
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  static const _defaultCenter = LatLng(7.748893528858868, 125.71679490516968);

  late final MapController _mapController;
  late LatLng _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final picked = widget.controller.pickedLatLng;
    _currentCenter = widget.initialPosition ?? picked ?? _defaultCenter;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _currentCenter = camera.center;
  }

  void _onConfirm() {
    widget.controller.confirmManualLocation(_currentCenter, label: 'Manually pinned');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final acc = widget.controller.accuracy;

    return Container(
      height: screenH * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pin Your Exact Location",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                      Text("Drag the map to move the pin to your scan location",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 16,
                    onPositionChanged: _onPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cacao.apps',
                      maxZoom: 19,
                    ),
                  ],
                ),
                // Fixed center pin
                IgnorePointer(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.agriculture, color: Colors.white, size: 22),
                        ),
                        Container(width: 3, height: 16, color: const Color(0xFF2E7D32)),
                        Container(
                          width: 10, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Accuracy banner
                Positioned(
                  top: 12, left: 12, right: 12,
                  child: _AccuracyBanner(accuracy: acc),
                ),
                // Zoom controls
                Positioned(
                  right: 12, bottom: 12,
                  child: Column(
                    children: [
                      _ZoomButton(icon: Icons.add, onTap: () => _mapController.move(_currentCenter, _mapController.camera.zoom + 1)),
                      const SizedBox(height: 4),
                      _ZoomButton(icon: Icons.remove, onTap: () => _mapController.move(_currentCenter, _mapController.camera.zoom - 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _onConfirm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Confirm This Location",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyBanner extends StatelessWidget {
  final double? accuracy;
  const _AccuracyBanner({this.accuracy});

  @override
  Widget build(BuildContext context) {
    final bool isOffline = accuracy == null;
    final bool isLow = !isOffline && accuracy! > 50;
    final color = (isOffline || isLow) ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    final icon = isOffline ? Icons.wifi_off : isLow ? Icons.gps_not_fixed : Icons.gps_fixed;
    final message = isOffline
        ? "No GPS signal — drag the pin to your exact location"
        : isLow
            ? "Low accuracy ±${accuracy!.toStringAsFixed(0)}m — drag to refine"
            : "GPS detected ±${accuracy!.toStringAsFixed(0)}m — adjust if needed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}