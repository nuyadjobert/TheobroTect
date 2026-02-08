import 'dart:async';
import 'package:cacao_apps/modules/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../disease/views/disease_detail_sheet.dart';

import '../widgets/weather_card.dart';
import '../widgets/total_scanned_card.dart';
import '../widgets/disease_slider.dart';
import '../widgets/inspection_card.dart';
import '../widgets/notification_icon.dart';
import '../../learn/views/learn_hub_screen.dart';
import '../../history/views/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _catalogKey = GlobalKey();
  final GlobalKey _scannerKey = GlobalKey();

  bool _showWeatherTip = false;
  int _currentIndex = 0;
  int _bottomNavIndex = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> _diseaseData = [
    {
      "image": "assets/images/pb_bg.png",
      "images": ["assets/images/pb1.png", "assets/images/pb2.png", "assets/images/pb3.png"],
      "title": "Cacao Pod Borer",
      "origin": "Southeast Asia",
      "description": "A small moth whose larvae tunnel into cocoa pods, disrupting bean development.",
      "symptoms": ["Premature ripening", "Uneven pod coloring", "Small exit holes", "Clumped, damaged beans"],
      "tagalog": {
        "description": "Isang maliit na gamu-gamo kung saan ang mga uod nito ay bumubutas sa loob ng bunga ng kakaw, na sumisira sa paglaki ng mga buto.",
        "symptoms": ["Maagang pagkahinog ng bunga", "Hindi pantay na kulay ng balat", "Maliit na mga butas sa labas ng bunga", "Magkakadikit at sirang mga buto sa loob"],
      },
    },
    {
      "image": "assets/images/bp_bg.png",
      "images": ["assets/images/bp1.png", "assets/images/bp2.png", "assets/images/bp3.png"],
      "title": "Black Pod Rot",
      "origin": "Worldwide (Tropical)",
      "description": "Caused by Phytophthora fungi, it spreads rapidly in wet conditions.",
      "symptoms": ["Expanding dark brown spots", "White fungal growth", "Firm rot on pod surface", "Rotted internal beans"],
      "tagalog": {
        "description": "Sanhi ng halamang-singaw na Phytophthora, mabilis itong kumakalat lalo na sa panahon ng tag-ulan o basang kapaligiran.",
        "symptoms": ["Lumalawak na maitim o kulay-kape na mga batik", "Puting amag sa ibabaw ng bunga", "Matigas na pagkabulok ng balat", "Mabahong pagkabulok ng mga buto sa loob"],
      },
    },
    {
      "image": "assets/images/mb_bg.png",
      "images": ["assets/images/mb1.png", "assets/images/mb2.png", "assets/images/mb3.png"],
      "title": "Mealybugs",
      "origin": "Global Tropics",
      "description": "Soft-bodied insects that suck sap and secrete honeydew, often spreading viruses.",
      "symptoms": ["White cottony clusters", "Sticky honeydew on leaves", "Sooty mold growth", "Yellowing of foliage"],
      "tagalog": {
        "description": "Malambot na insekto na sumisipsip ng dagta ng puno at naglalabas ng malagkit na likido na nagiging sanhi ng virus.",
        "symptoms": ["Mapuputi at parang bulak na kumpol sa sanga o bunga", "Malagkit na likido sa mga dahon", "Pangungitim o pagkakaroon ng maitim na amag (sooty mold)", "Pagkapanilaw ng mga dahon"],
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _diseaseData.length;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        _profileKey,
        _catalogKey,
        _scannerKey,
      ]);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showDiseaseDetails(Map<String, dynamic> disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiseaseDetailSheet(disease: disease),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF5FAF3),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FAF3),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _bottomNavIndex = index);
          },
          children: [
            _buildHomeContent(), 
            const HistoryScreen(), 
            const LearnHubScreen(), 
            const SettingsScreen(), 
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          selectedItemColor: const Color(0xFF2D6A4F),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: const [
BottomNavigationBarItem(
    icon: Icon(Icons.eco_outlined), // Looks like a Cacao Leaf/Pod
    activeIcon: Icon(Icons.eco_rounded),
    label: 'Home',
  ),            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
BottomNavigationBarItem(
    icon: Icon(Icons.tune_rounded),
    activeIcon: Icon(Icons.settings_input_component_rounded),
    label: 'Settings',
  ),],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Showcase(
                      key: _profileKey,
                      title: 'Your Profile',
                      description: 'Manage your farm settings and account details here.',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green.withAlpha((0.2 * 255).toInt()), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF1F1F1),
                          child: Icon(Icons.person_outline, color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good Morning,", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const Text("Farmer John!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      ],
                    ),
                    const Spacer(),
                    const NotificationIcon(),
                  ],
                ),
                const SizedBox(height: 20),
                WeatherCard(
                  showWeatherTip: _showWeatherTip,
                  onTap: () => setState(() => _showWeatherTip = !_showWeatherTip),
                ),
                const SizedBox(height: 15),
                Showcase(
                  key: _catalogKey,
                  title: 'Disease Catalog',
                  description: 'Tap or swipe to see symptoms of common cacao diseases.',
                  child: DiseaseSlider(
                    diseaseData: _diseaseData,
                    currentIndex: _currentIndex,
                    onTap: () => _showDiseaseDetails(_diseaseData[_currentIndex]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text("Quick Inspection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Showcase(
                    key: _scannerKey,
                    title: 'AI Scanner',
                    description: 'Use your camera to identify diseases in the field.',
                    child: const InspectionCard(),
                  ),
                  const SizedBox(height: 25),
                  const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const TotalScannedCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}