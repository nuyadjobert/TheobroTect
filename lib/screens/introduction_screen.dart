import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth/login_screen.dart'; // Import path to your login screen

// Import separated widgets
import '../widgets/intro/intro_background.dart';
import '../widgets/intro/intro_skip_button.dart';
import '../widgets/intro/intro_content_page.dart';
import '../widgets/intro/intro_page_indicators.dart';
import '../widgets/intro/intro_action_button.dart';

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
            IntroBackground(
              currentPage: _currentPage,
              introData: introData,
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
                  IntroSkipButton(
                    onSkip: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                        return IntroContentPage(
                          title: introData[index]['title']!,
                          description: introData[index]['desc']!,
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
                        IntroPageIndicators(
                          currentPage: _currentPage,
                          pageCount: introData.length,
                          primaryGreen: primaryGreen,
                        ),
                        const SizedBox(height: 30),

                        // Action Button
                        IntroActionButton(
                          currentPage: _currentPage,
                          totalPages: introData.length,
                          primaryGreen: primaryGreen,
                          onPressed: _handleNext,
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