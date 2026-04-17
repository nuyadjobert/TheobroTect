import 'dart:ui';
import 'package:cacao_apps/core/sync/sync_trigger.dart';
import 'package:cacao_apps/modules/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shimmer/shimmer.dart';
import '../../disease/views/disease_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:cacao_apps/core/db/app_database.dart';

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

  final List<Map<String, dynamic>> _diseaseData = [
    {
      "image": "assets/images/pb_bg.png",
      "images": [
        "assets/images/pb1.png",
        "assets/images/pb2.png",
        "assets/images/pb3.png",
      ],
      "title": "Cacao Pod Borer",
      "origin": "Southeast Asia",
      "description":
          "A small moth whose larvae tunnel into cocoa pods, disrupting bean development.",
      "symptoms": [
        "Premature ripening",
        "Uneven pod coloring",
        "Small exit holes",
        "Clumped, damaged beans",
      ],
      "tagalog": {
        "description":
            "Isang maliit na gamu-gamo kung saan ang mga uod nito ay bumubutas sa loob ng bunga ng kakaw, na sumisira sa paglaki ng mga buto.",
        "symptoms": [
          "Maagang pagkahinog ng bunga",
          "Hindi pantay na kulay ng balat",
          "Maliit na mga butas sa labas ng bunga",
          "Magkakadikit at sirang mga buto sa loob",
        ],
      },
    },
    {
      "image": "assets/images/bp_bg.png",
      "images": [
        "assets/images/bp1.png",
        "assets/images/bp2.png",
        "assets/images/bp3.png",
      ],
      "title": "Black Pod Rot",
      "origin": "Worldwide (Tropical)",
      "description":
          "Caused by Phytophthora fungi, it spreads rapidly in wet conditions.",
      "symptoms": [
        "Expanding dark brown spots",
        "White fungal growth",
        "Firm rot on pod surface",
        "Rotted internal beans",
      ],
      "tagalog": {
        "description":
            "Sanhi ng halamang-singaw na Phytophthora, mabilis itong kumakalat lalo na sa panahon ng tag-ulan o basang kapaligiran.",
        "symptoms": [
          "Lumalawak na maitim o kulay-kape na mga batik",
          "Puting amag sa ibabaw ng bunga",
          "Matigas na pagkabulok ng balat",
          "Mabahong pagkabulok ng mga buto sa loob",
        ],
      },
    },
    {
      "image": "assets/images/mb_bg.png",
      "images": [
        "assets/images/mb1.png",
        "assets/images/mb2.png",
        "assets/images/mb3.png",
      ],
      "title": "Mealybugs",
      "origin": "Global Tropics",
      "description":
          "Soft-bodied insects that suck sap and secrete honeydew, often spreading viruses.",
      "symptoms": [
        "White cottony clusters",
        "Sticky honeydew on leaves",
        "Sooty mold growth",
        "Yellowing of foliage",
      ],
      "tagalog": {
        "description":
            "Malambot na insekto na sumisipsip ng dagta ng puno at naglalabas ng malagkit na likido na nagiging sanhi ng virus.",
        "symptoms": [
          "Mapuputi at parang bulak na kumpol sa sanga o bunga",
          "Malagkit na likido sa mga dahon",
          "Pangungitim o pagkakaroon ng maitim na amag (sooty mold)",
          "Pagkapanilaw ng mga dahon",
        ],
      },
    },
  ];

Future<void> _checkPendingScans() async {
  final db = AppDatabase();

  final user = await db.getCurrentUser();
  if (user == null) {
    debugPrint("❌ [HOME] No user found");
    return;
  }

  final pending = await db.getPendingScans(userId: user.userId);

  debugPrint("📦 [HOME] Pending scans count: ${pending.length}");

  for (var scan in pending) {
    debugPrint("➡️ [HOME] Pending local_id: ${scan['local_id']}");
  }
}

  final _syncTrigger = SyncTrigger();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller.startBackgroundServices().then((_) {
      if (mounted) setState(() {});
    });
    _syncTrigger.start();
    _checkPendingScans();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.get().startShowCase([_profileKey, _catalogKey, _scannerKey]);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _syncTrigger.stop();
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
                    diseaseData: _diseaseData,
                    onDiseaseTap: (index) {
                      _showDiseaseDetails(_diseaseData[index]);
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
      case 1: // History Skeleton
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 8,
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 2: // Learn Skeleton
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
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, _) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 3: // Settings Skeleton
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 15),
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 40),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      default: // Home Skeleton
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 160, height: 20, color: Colors.white),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 30),
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        );
    }
  }
}
