import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DiseaseMapScreen extends StatefulWidget {
  const DiseaseMapScreen({super.key});

  @override
  State<DiseaseMapScreen> createState() => _DiseaseMapScreenState();
}

class _DiseaseMapScreenState extends State<DiseaseMapScreen> {
  // Center the map on Tagum City, Davao
  final LatLng _tagumCity = const LatLng(7.4478, 125.8080);

  // Simulated Disease Outbreaks nearby
  final List<Map<String, dynamic>> _outbreaks = [
    {'loc': const LatLng(7.4520, 125.8100), 'type': 'Black Pod Rot', 'radius': 400.0, 'color': Colors.red},
    {'loc': const LatLng(7.4420, 125.7980), 'type': 'Stem Canker', 'radius': 250.0, 'color': Colors.orange},
    {'loc': const LatLng(7.4550, 125.8150), 'type': 'Vascular Streak', 'radius': 300.0, 'color': Colors.redAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE REAL MAP (OpenStreetMap)
          FlutterMap(
            options: MapOptions(
              initialCenter: _tagumCity, // Start at Tagum
              initialZoom: 14.5, // Good zoom level for a city view
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // Allow pinch, zoom, drag
              ),
            ),
            children: [
              // A. Map Tiles (The visual map)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cacao_apps',
                maxZoom: 19,
              ),

              // B. Danger Zones (Circles)
              CircleLayer(
                circles: _outbreaks.map((data) {
                  return CircleMarker(
                    point: data['loc'],
                    radius: data['radius'], // Size of outbreak
                    useRadiusInMeter: true, // Key for accurate sizing
                    color: (data['color'] as Color).withOpacity(0.3), // Transparent fill
                    borderColor: (data['color'] as Color),
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),

              // C. Markers (Pins)
              MarkerLayer(
                markers: [
                  // User Location Marker (You)
                  Marker(
                    point: _tagumCity,
                    width: 60,
                    height: 60,
                    child: _buildUserMarker(),
                  ),
                  
                  // Disease Markers
                  ..._outbreaks.map((data) {
                    return Marker(
                      point: data['loc'],
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: data['color'], size: 40),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Top Floating Bar (Glassmorphism)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Your Location", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              "Tagum City, Davao", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Info Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("High Risk Zone", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("3 confirmed Black Pod cases within 500m", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _buildUserMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
        ),
      ],
    );
  }
}