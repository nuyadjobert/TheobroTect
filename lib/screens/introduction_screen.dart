import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth/login_screen.dart'; // Import path to your login screen

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  // Controller to handle page swiping
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Structured Data for the Introduction slides
  final List<Map<String, String>> introData = [
    {
      'title': 'TheobroTect ML',
      'desc': 'Protect your harvest. Detect cacao diseases instantly and get expert treatment plans.',
      'image': 'assets/images/img1.png',
    },
    {
      'title': 'Smart Detection',
      'desc': 'Our advanced machine learning models identify diseases with just a simple photo.',
      'image': 'assets/images/img2.png',
    },
    {
      'title': 'Disease Heatmaps',
      'desc': 'Track outbreaks in real-time. Visualize high-risk areas across your plantation to stay ahead.',
      'image': 'assets/images/img3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle the primary button logic
  void _handleNext() {
    if (_currentPage < introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // NAVIGATION UPDATED: Skips Onboarding and goes to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a fallback primary color if your theme isn't set yet
    final Color primaryGreen = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            // --- 1. BACKGROUND LAYER (The Melt Transition) ---
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  introData[_currentPage]['image']!,
                  key: ValueKey<int>(_currentPage),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  // Error handling for missing assets
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                ),
              ),
            ),

            // --- 2. GRADIENT OVERLAY (Readability & Protection) ---
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // --- 3. UI CONTENT LAYER ---
            SafeArea(
              child: Column(
                children: [
                  // Top Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        ),
                        style: TextButton.styleFrom(backgroundColor: Colors.white12),
                        child: const Text("SKIP", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),

                  // Swipeable Content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: introData.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                introData[index]['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                introData[index]['desc']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Controls (Indicators + Button)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                    child: Column(
                      children: [
                        // Smooth Page Indicators
                        Row(
                          children: List.generate(
                            introData.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? primaryGreen : Colors.white38,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _handleNext,
                            child: Text(
                              _currentPage == introData.length - 1
                                  ? "GET STARTED"
                                  : "NEXT",
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}