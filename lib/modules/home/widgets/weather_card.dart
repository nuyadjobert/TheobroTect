import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  final bool showWeatherTip;
  final VoidCallback onTap;

  const WeatherCard({
    super.key,
    required this.showWeatherTip,
    required this.onTap,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;
  bool _loading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadWeather();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      // Get device's current location
      Position position = await _getCurrentLocation();
      
      // Fetch weather using current coordinates
      final result = await _weatherService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      
      setState(() {
        _weather = result;
        _loading = false;
      });
      _fadeController.forward();
    } catch (e) {
      print('Weather fetch error: $e');
      setState(() => _loading = false);
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If GPS is off, use fallback location (Polomolok)
      return Position(
        latitude: 6.6397,
        longitude: 125.0583,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, use fallback
        return Position(
          latitude: 6.6397,
          longitude: 125.0583,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied, use fallback
      return Position(
        latitude: 6.6397,
        longitude: 125.0583,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Get actual current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF2D6A4F);
    const Color darkGreen = Color(0xFF1B4332);

    if (_loading) {
      return SizedBox(
        width: double.infinity,
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: brandGreen,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_weather == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withAlpha((0.3 * 255).toInt()),
          border: Border.all(
            color: brandGreen.withAlpha((0.15 * 255).toInt()),
            width: 1,
          ),
        ),
        child: const Text(
          "Weather unavailable",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    // Weather info
    bool isRainyExpected = ['Rain', 'Thunderstorm', 'Drizzle', 'Squall']
        .contains(_weather!.condition);
    String weatherCondition = _weather!.condition;
    String temperature = "${_weather!.temperature.round()}°C";
    String city = _weather!.city;

    // Advisory tip
    String tipMessage = isRainyExpected
        ? "Rain expected soon. Avoid spraying to prevent wash-off."
        : "Weather is clear. Ideal time for field work.";

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withAlpha((0.3 * 255).toInt()),
          border: Border.all(
            color: brandGreen.withAlpha((0.15 * 255).toInt()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).toInt()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isRainyExpected)
                        const Icon(Icons.cloud_outlined,
                            color: brandGreen, size: 18)
                      else
                        const SizedBox(width: 18), // align text
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: darkGreen,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            weatherCondition,
                            style: TextStyle(
                              color: brandGreen.withAlpha((0.7 * 255).toInt()),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        temperature,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        widget.showWeatherTip
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: brandGreen,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.showWeatherTip) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  color: brandGreen.withAlpha((0.15 * 255).toInt()),
                  thickness: 1,
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.5 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tips_and_updates_outlined,
                        color: Color(0xFFE5A500),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "FARMER'S ADVISORY",
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: brandGreen,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            tipMessage,
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              color: darkGreen.withAlpha((0.8 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}