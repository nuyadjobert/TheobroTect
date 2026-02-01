import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/disease_detail_sheet.dart';
import 'scanner_screen.dart';
import 'disease_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Disease Data
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
        "symptoms": [
          "Maagang pagkahinog ng bunga",
          "Hindi pantay na kulay ng balat",
          "Maliit na mga butas sa labas ng bunga",
          "Magkakadikit at sirang mga buto sa loob"
        ],
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
        "symptoms": [
          "Lumalawak na maitim o kulay-kape na mga batik",
          "Puting amag sa ibabaw ng bunga",
          "Matigas na pagkabulok ng balat",
          "Mabahong pagkabulok ng mga buto sa loob"
        ],
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
        "symptoms": [
          "Mapuputi at parang bulak na kumpol sa sanga o bunga",
          "Malagkit na likido sa mga dahon",
          "Pangungitim o pagkakaroon ng maitim na amag (sooty mold)",
          "Pagkapanilaw ng mga dahon"
        ],
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll the slider
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _diseaseData.length;
        });
      }
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FIXED HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header
                  Row(
                    children: [
                      Container(
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
                  const SizedBox(height: 25),
                  
                  // Section Header
                  _buildSectionHeader("Common Diseases", "CATALOG"),
                  const SizedBox(height: 10),
                  
                  // Cinematic Glass Slider
                  _buildEnhancedSlider(),
                ],
              ),
            ),

            // --- SCROLLABLE SECTION ---
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
                    _buildInspectionCard(),
                    const SizedBox(height: 30),
                    const Text("Health Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildAlertCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFD8F3DC), // Light mint
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(action, style: const TextStyle(color: Color(0xFF2D6A4F), fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- ENHANCED SLIDER (COMPACT GLASS BOX) ---
  Widget _buildEnhancedSlider() {
    return GestureDetector(
      onTap: () => _showDiseaseDetails(_diseaseData[_currentIndex]),
      child: Container(
        height: 240, 
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. The Animated Image
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

              // 2. Gradient overlay
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

              // 3. Top Right Badge
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
                      Text(
                        "Common Threat", 
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. COMPACT Floating Glass Info Card
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  // Reduced padding to make it smaller/slimmer
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7), // Slightly darker for better contrast
                    borderRadius: BorderRadius.circular(20), // Slightly smaller radius
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Smaller Font Size
                          Text(
                            _diseaseData[_currentIndex]["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16, // Reduced from 20
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.public, color: Colors.white70, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                _diseaseData[_currentIndex]["origin"] ?? "Unknown",
                                style: const TextStyle(color: Colors.white70, fontSize: 11), // Smaller text
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Smaller Arrow Button
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 5. Slider Indicator Dots
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScannerScreen()),
                      );
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

  Widget _buildAlertCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiseaseMapScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5F5), Color(0xFFFFF0F0)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                Icons.map_outlined,
                size: 100,
                color: Colors.redAccent.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    height: 56, width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_location_alt_rounded, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Disease Outbreak", 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16, 
                                color: Color(0xFF2D3436)
                              )
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "LIVE", 
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "High risk of Black Pod Rot detected near Tagum City.", 
                          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.redAccent, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Icon(Icons.notifications_outlined, size: 24, color: Colors.black87),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}