import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import '../widgets/disease_detail_sheet.dart';
import 'scanner_screen.dart';
import 'disease_map_screen.dart';
import 'dart:ui';

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
        systemNavigationBarColor: Color(0xFFFBFDFB),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFDFB),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _bottomNavIndex = index);
          },
          children: [
            _buildHomeContent(), // Index 0
            const Center(child: Text("History Screen")), // Index 1
            const Center(child: Text("Learn Screen")), // Index 2
            const Center(child: Text("Settings Screen")), // Index 3
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
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
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
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
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
                    _buildNotificationIcon(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWeatherCard(),
                const SizedBox(height: 15),
                Showcase(
                  key: _catalogKey,
                  title: 'Disease Catalog',
                  description: 'Tap or swipe to see symptoms of common cacao diseases.',
                  child: _buildEnhancedSlider(),
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
                    child: _buildInspectionCard(),
                  ),
                  const SizedBox(height: 25),
                  const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTotalScannedCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- RESTORED ORIGINAL WIDGETS ---

  Widget _buildWeatherCard() {
    bool isRainyExpected = true;
    String weatherCondition = "Showers Expected";
    const Color brandGreen = Color(0xFF2D6A4F);
    const Color darkGreen = Color(0xFF1B4332);
    const Color mintBg = Color(0xFFD8F3DC);

    return GestureDetector(
      onTap: () => setState(() => _showWeatherTip = !_showWeatherTip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mintBg.withOpacity(0.7),
              const Color(0xFFF1F8E9),
            ],
          ),
          border: Border.all(color: brandGreen.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: brandGreen.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isRainyExpected ? Icons.cloud_outlined : Icons.wb_sunny_outlined,
                      color: brandGreen,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tagum City", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkGreen, letterSpacing: -0.5)),
                        Text(weatherCondition, style: TextStyle(color: brandGreen.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("26°C", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGreen)),
                    const SizedBox(width: 8),
                    Icon(_showWeatherTip ? Icons.expand_less : Icons.expand_more, color: brandGreen),
                  ],
                ),
              ],
            ),
            if (_showWeatherTip) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: brandGreen.withOpacity(0.1), thickness: 1),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                    child: const Icon(Icons.tips_and_updates_outlined, color: Color(0xFFE5A500), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("FARMER'S ADVISORY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: brandGreen, letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        Text(
                          isRainyExpected ? "Rain expected soon. Avoid spraying to prevent wash-off." : "Clear skies. Perfect for harvesting or sun-drying beans.",
                          style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500, color: darkGreen.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScannedCard() {
    const Color brandGreen = Color(0xFF2D6A4F);
    const Color darkGreen = Color(0xFF1B4332);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: brandGreen.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: 38 / 45,
                      strokeWidth: 6,
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(brandGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const Icon(Icons.analytics_outlined, size: 20, color: darkGreen),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Farm Health Summary", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkGreen)),
                    Text("Based on your last 45 scans", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider(height: 1, thickness: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnhancedStatItem("45", "Total Scans", Colors.blueGrey),
              _buildEnhancedStatItem("38", "Healthy", brandGreen),
              _buildEnhancedStatItem("07", "Diseased", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Container(height: 3, width: 20, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.2)),
      ],
    );
  }

  Widget _buildEnhancedSlider() {
    return GestureDetector(
      onTap: () => _showDiseaseDetails(_diseaseData[_currentIndex]),
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 25, offset: const Offset(0, 15)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _diseaseData[_currentIndex]["image"]!,
                  key: ValueKey<int>(_currentIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 12),
                      SizedBox(width: 4),
                      Text("Common Disease's", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_diseaseData[_currentIndex]["title"]!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.public, color: Colors.white70, size: 10),
                              const SizedBox(width: 4),
                              Text(_diseaseData[_currentIndex]["origin"] ?? "Unknown", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 25,
                child: Row(
                  children: _diseaseData.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentIndex == entry.key ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FULL DESIGN AI SCANNER CARD ---
  Widget _buildInspectionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD8F3DC), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.eco,
              size: 150,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.qr_code_scanner, color: Color(0xFF2D6A4F), size: 28),
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Scanner", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text("Check Your Pods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Detect diseases instantly using our AI camera.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF40916C)),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      shadowColor: const Color(0xFF2D6A4F).withOpacity(0.4),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Text("START SCANNING", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
          child: const Icon(Icons.notifications_outlined, size: 24, color: Colors.black87),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            height: 10, width: 10,
            decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          ),
        ),
      ],
    );
  }
}