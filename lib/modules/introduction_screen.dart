import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cacao_apps/modules/auth/login_factory.dart';

import '../core/widgets/intro/intro_background.dart';
import '../core/widgets/intro/intro_skip_button.dart';
import '../core/widgets/intro/intro_content_page.dart';
import '../core/widgets/intro/intro_page_indicators.dart';
import '../core/widgets/intro/intro_action_button.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  void _handleNext() {
    if (_currentPage < introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => buildLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            IntroBackground(
              currentPage: _currentPage,
              introData: introData,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Colors.black.withAlpha((0.7 * 255).toInt()),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withAlpha((0.9 * 255).toInt()),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  IntroSkipButton(
                    onSkip: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => buildLoginScreen()),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                    child: Column(
                      children: [
                        IntroPageIndicators(
                          currentPage: _currentPage,
                          pageCount: introData.length,
                          primaryGreen: primaryGreen,
                        ),
                        const SizedBox(height: 30),

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