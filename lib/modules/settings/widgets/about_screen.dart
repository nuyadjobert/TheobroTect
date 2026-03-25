import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemUiOverlayStyle

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This ensures the status bar icons (time, battery) are DARK and visible
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Keeps the status bar seamless
        statusBarIconBrightness: Brightness.dark, // Dark icons for Android
        statusBarBrightness: Brightness.light, // Dark icons for iOS
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          // Secondary backup to ensure status bar icons stay visible
          systemOverlayStyle: SystemUiOverlayStyle.dark, 
          leading: const BackButton(color: Color(0xFF1B3022)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // --- EXTENDED SYSTEM INTRODUCTION ---
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D6A4F),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D6A4F).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "TheobroTect",
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        color: Color(0xFF1B3022),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      "Version 1.0.4",
                      style: TextStyle(
                        color: Color(0xFF2D6A4F), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "TheobroTect represents a breakthrough in digital agriculture, specifically tailored for the 'Theobroma Cacao' farmers of the Davao Region. Our system serves as a bridge between traditional farming wisdom and modern Artificial Intelligence. By utilizing advanced image recognition algorithms, we empower farmers to identify complex diseases—such as Black Pod Rot or Mealybug Cacao disease, directly from their mobile devices.\n\nBeyond diagnostics, TheobroTect is a comprehensive ecosystem designed to foster sustainability. We believe that by providing precision farming insights and real-time alerts, we can significantly reduce crop loss, optimize resource management, and ultimately elevate the livelihood of the local farming community. Together, we are protecting the future of Philippine cacao, one tree at a time.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15, 
                          height: 1.7, 
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              const Divider(thickness: 1, color: Color(0xFFE8EDE8)),
              const SizedBox(height: 40),

              // --- CENTERED TEAM SECTION ---
              const Text(
                "OUR DEDICATED TEAM",
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.grey, 
                  letterSpacing: 3.0
                ),
              ),
              const SizedBox(height: 40),

              _buildTeamMember(
                name: "Jay Wendyl Bagsic",
                role: "System Analyst",
              ),
              _buildTeamDivider(),

              _buildTeamMember(
                name: "Rodgie Federio",
                role: "Documentarian",
              ),
              _buildTeamDivider(),

              _buildTeamMember(
                name: "Jayson Butawan",
                role: "Senior/Lead Developer",
              ),
              _buildTeamDivider(),

              _buildTeamMember(
                name: "Jobert Noyad",
                role: "Junior Developer",
              ),
              
              const SizedBox(height: 80),
              const Text(
                "Made with ❤️ in the Philippines",
                style: TextStyle(
                  color: Colors.grey, 
                  fontSize: 11, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required String name, 
    required String role,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFFF0F0F0),
            backgroundImage: AssetImage('assets/images/image.png'), 
          ),
        ),
        const SizedBox(height: 18),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3022),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2D6A4F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF2D6A4F),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamDivider() {
    return Container(
      height: 40,
      width: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withOpacity(0.0), 
            Colors.grey.withOpacity(0.3), 
            Colors.grey.withOpacity(0.0)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}