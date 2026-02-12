import 'dart:async';
import 'dart:ui';
import 'package:cacao_apps/modules/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shimmer/shimmer.dart'; 
import '../../disease/views/disease_detail_sheet.dart';

import '../widgets/weather_card.dart';
import '../widgets/total_scanned_card.dart';
import '../widgets/disease_slider.dart';
import '../widgets/inspection_card.dart';
import '../widgets/notification_icon.dart';
import '../../learn/views/learn_hub_screen.dart';
import '../../history/views/history_screen.dart';
import '../../notifications/views/notification_screen.dart';

import '../../introduction/widgets/loading_screen.dart'; 

import '../widgets/nav_drawer_header.dart';
import '../widgets/nav_farm_info.dart';
import '../widgets/nav_stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _catalogKey = GlobalKey();
  final GlobalKey _scannerKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showWeatherTip = false;
  int _currentIndex = 0;
  int _bottomNavIndex = 0;
  int _targetIndex = 0; // NEW: Tracks which page we are moving TO
  late PageController _pageController;

  bool _isLoading = false;

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
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF5FAF3),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5FAF3),
        drawer:const Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
               NavDrawerHeader(),
               NavFarmInfo(),
               NavStatsCard(),
            ],
          ),
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe during loading
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
            
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF5FAF3),
                  child: Stack(
                    children: [
                      // Pass targetIndex so the skeleton matches the incoming page
                      SkeletonLayout(pageIndex: _targetIndex),
                      
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: const Color(0xFFF5FAF3).withAlpha(102), 
                          child: const Center(
                            child: TheobroTectLoader(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) async {
            if (index == _bottomNavIndex) return;

            setState(() {
              _targetIndex = index; // Set which skeleton to show
              _isLoading = true;
            });

            await Future.delayed(const Duration(milliseconds: 5100));

            if (mounted) {
              _pageController.jumpToPage(index); 
              setState(() {
                _bottomNavIndex = index;
                _isLoading = false;
              });
            }
          },
          selectedItemColor: const Color(0xFF2D6A4F),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.settings_input_component_rounded),
              label: 'Settings',
            ),
          ],
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
                      child: GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: NotificationIcon(),
                      ),
                    ),
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

class SkeletonLayout extends StatelessWidget {
  final int pageIndex;
  const SkeletonLayout({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: _buildSkeletonContent(),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    switch (pageIndex) {
      case 1: // History Skeleton (List style)
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 8,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 15, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 2: // Learn Skeleton (Grid style)
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 200, height: 25, color: Colors.white),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8
                  ),
                  itemCount: 4,
                  itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ],
          ),
        );
      case 3: // Settings Skeleton (Profile + Tiles)
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(width: 100, height: 100, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(height: 15),
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 40),
              ...List.generate(5, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(width: double.infinity, height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              )),
            ],
          ),
        );
      default: // Home Skeleton (Dashboard style)
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 160, height: 20, color: Colors.white),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
              const SizedBox(height: 20),
              Container(width: double.infinity, height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 30),
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 15),
              Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
            ],
          ),
        );
    }
  }
}