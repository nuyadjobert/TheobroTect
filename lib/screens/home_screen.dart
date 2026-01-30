import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // List of your images and titles
  final List<Map<String, String>> _diseaseData = [
    {"image": "assets/images/img1.png", "title": "Frosty Pod Rot"},
    {"image": "assets/images/img2.png", "title": "Black Pod Rot"},
    {"image": "assets/images/img3.png", "title": "Cacao Swollen Shoot"}, // Updated title for variety
  ];

  @override
  void initState() {
    super.initState();
    // Changes the index every 4 seconds to trigger the fade
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _diseaseData.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 1. TOP HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello, Farmer!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Monitor your cacao health", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none, size: 28),
                ],
              ),

              const SizedBox(height: 25),

              // 2. SECTION TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Common Diseases", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    child: const Text("CATALOG", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 3. THE FADING IMAGE CONTAINER
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000), 
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey<int>(_currentIndex), 
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(_diseaseData[_currentIndex]["image"]!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Keeps container tight around text
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _diseaseData[_currentIndex]["title"]!,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.touch_app, color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Tap to learn more", 
                              style: TextStyle(color: Colors.white70, fontSize: 11)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}