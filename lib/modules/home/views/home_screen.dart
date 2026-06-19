import 'dart:ui';
import 'package:cacao_apps/modules/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../disease/views/disease_detail_sheet.dart';

import '../widgets/total_scanned_card.dart';
import '../widgets/disease_slider.dart';
import '../widgets/inspection_card.dart';
import '../widgets/notification_icon.dart';
import '../../learn/views/learn_hub_screen.dart';
import '../../history/views/history_screen.dart';
import '../../notifications/views/notification_screen.dart';
import '../../scan/views/scanner_screen.dart';
import '../../introduction/widgets/loading_screen.dart';

import '../widgets/nav_drawer_header.dart';
import '../widgets/nav_farm_info.dart';
import '../widgets/nav_stats_card.dart';
import '../Controller/home_controller.dart';
import '../views/skeleton_loading.dart';

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
  
  final HomeController _controller = HomeController();

  int _bottomNavIndex = 0;
  int _targetIndex = 0;
  late PageController _pageController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _controller.startBackgroundServices().then((_) {
      if (mounted) setState(() {});
    });
    
    // Using controller methods instead of handling it directly in view
    _controller.startSync();
    _controller.checkPendingScans();
    _controller. syncGuideData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.get().startShowCase([_profileKey, _catalogKey, _scannerKey]);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.stopSync(); // Delegate to controller
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

  void _handleNavigation(int index) async {
    if (index == _bottomNavIndex) return;

    setState(() {
      _targetIndex = index;
      _isLoading = true;
    });

    try {
      await _controller.fetchData(index);
    } catch (e) {
      debugPrint("Navigation Error: $e");
    } finally {
      if (mounted) {
        _pageController.jumpToPage(index);
        setState(() {
          _bottomNavIndex = index;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5FAF3),
        extendBody: true,
        resizeToAvoidBottomInset: false,
        drawer: const Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [NavDrawerHeader(), NavFarmInfo(), NavStatsCard()],
          ),
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
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
                      SkeletonLayout(pageIndex: _targetIndex),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: const Color(0xFFF5FAF3).withAlpha(102),
                          child: const Center(child: TheobroTectLoader()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SizedBox(
            height: 54,
            width: 54,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScannerScreen()),
                );
              },
              backgroundColor: const Color(0xFF2D6A4F),
              elevation: 5,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          elevation: 20,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.eco_outlined, Icons.eco_rounded, "Home"),
                _buildNavItem(
                  1,
                  Icons.history_rounded,
                  Icons.history_rounded,
                  "History",
                ),
                const SizedBox(width: 40),
                _buildNavItem(
                  2,
                  Icons.menu_book_rounded,
                  Icons.menu_book_rounded,
                  "Learn",
                ),
                _buildNavItem(
                  3,
                  Icons.tune_rounded,
                  Icons.settings_input_component_rounded,
                  "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    bool isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? const Color(0xFF2D6A4F) : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFF2D6A4F) : Colors.grey[500],
            ),
          ),
        ],
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
                      description:
                          'Manage your farm settings and account details here.',
                      child: GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFF1F1F1),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.getGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${_controller.userName ?? 'Farmer'}!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
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
                Showcase(
                  key: _catalogKey,
                  title: 'Disease Catalog',
                  description:
                      'Tap or swipe to see symptoms of common cacao diseases.',
                  child: DiseaseSlider(
                    diseaseData: _controller.diseaseData,
                    onDiseaseTap: (index) {
                      _showDiseaseDetails(_controller.diseaseData[index]);
                    },
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
                  const Text(
                    "Quick Inspection",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Showcase(
                    key: _scannerKey,
                    title: 'AI Scanner',
                    description:
                        'Use your camera to identify diseases in the field.',
                    child: const InspectionCard(),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Recent Activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const TotalScannedCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

