import 'package:flutter/material.dart';
import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:cacao_apps/core/model/user.model.dart';

class NavFarmInfo extends StatelessWidget {
  const NavFarmInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Claymorphism Base Colors
    final baseColor = isDark ? const Color(0xFF23352A) : const Color(0xFFE8F0EA);
    final labelColor = isDark ? Colors.white54 : Colors.grey[700]!;
    final iconColor = isDark ? const Color(0xFF74C69D) : const Color(0xFF2D6A4F);
    final textColor = isDark ? Colors.white : const Color(0xFF1B3022);

    final UserRepository userRepository = UserRepository();

    return FutureBuilder<LocalUser?>(
      future: userRepository.getCurrentUser(),
      builder: (context, snapshot) {
        Widget content;

        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = Text("Loading...", style: TextStyle(color: labelColor));
        }
        // ❌ Error state
        else if (snapshot.hasError) {
          content = const Text("Error loading data", style: TextStyle(color: Colors.red));
        }
        // ✅ Data ready
        else {
          final user = snapshot.data;
          final String location = user?.address ?? "Sawata";
          
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on_rounded, location, iconColor, textColor, isDark),
              
              // Add other rows/contact info here later if needed
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_rounded, "+63 912 345 6789", iconColor, textColor, isDark),
            ],
          );
        }

        // The Claymorphic Container Wrapper
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(32), // 1. Extremely rounded corners
            boxShadow: [
              // 2. Outer shadow for floating depth
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.5) : const Color(0xFFB8C8BD),
                offset: const Offset(8, 8),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              // Optional: Soft light shadow for top-left (Neumorphic touch)
              BoxShadow(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                offset: const Offset(-6, -6),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            // 3. Inner gradient for the 3D "inflated clay" volume effect
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.white.withOpacity(0.1), Colors.black.withOpacity(0.2)]
                    : [Colors.white.withOpacity(0.7), Colors.black.withOpacity(0.03)],
                stops: const [0.1, 0.9],
              ),
            ),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color iconColor,
    Color textColor,
    bool isDark,
  ) {
    return Row(
      children: [
        // Mini clay container for the icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white,
              width: 1.5, // Highlight border to fake an inner bevel
            ),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  // Adjusted Empty State to match the Claymorphism style
  Widget _buildEmptyState(Color titleColor, Color labelColor, Color accentGreen, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white,
              width: 2,
            ),
          ),
          child: Icon(Icons.contact_phone_rounded, size: 32, color: accentGreen),
        ),
        const SizedBox(height: 16),
        Text(
          "No Contact Provided",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor),
        ),
        const SizedBox(height: 6),
        Text(
          "Please add a contact number for emergencies.",
          style: TextStyle(fontSize: 13, color: labelColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Claymorphic Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentGreen.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              debugPrint("Add contact tapped");
            }, 
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text("Add Contact"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              foregroundColor: Colors.white,
              elevation: 0, // Handled by outer container
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        )
      ],
    );
  }
}