import 'package:flutter/material.dart';
import '../widgets/guide_card.dart';
import '../widgets/prevention_tip_card.dart';
import '../widgets/management_sheet.dart'; 
import '../widgets/mastery_detail_screen.dart'; 
import '../models/guide_model.dart';      

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 100,
            floating: true,
            backgroundColor: Color(0xFFF9FBF9),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text("Knowledge Hub", 
                style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               
                  const SizedBox(height: 32),
                  _buildSectionHeader("Prevention Tip"),
                  const PreventionTipCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Mastery Courses"),
                  _buildHorizontalGuides(context), // Passed context here
                  const SizedBox(height: 32),
                  _buildSectionHeader("Management Guides"),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildManagementTile(context, Icons.agriculture_rounded, "Optimizing Shade", "Learn how to balance sunlight for better yields."),
              _buildManagementTile(context, Icons.water_drop_outlined, "Smart Irrigation", "Water conservation during the dry season."),
              _buildManagementTile(context, Icons.inventory_2_outlined, "Storage Basics", "Keep beans dry and pest-free after harvest."),
              _buildManagementTile(context, Icons.handyman_outlined, "Tool Maintenance", "Sharpening and rust prevention for tools."),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B3022))),
    );
  }

 

  // Updated to handle click navigation for Mastery Courses
  Widget _buildHorizontalGuides(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GuideCard(
            title: "Soil Fertility Secrets", 
            duration: "8 min", 
            themeColor: Colors.brown,
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const MasteryDetailScreen(title: "Soil Fertility Secrets", themeColor: Colors.brown))
            ),
          ),
          GuideCard(
            title: "Rainy Season Care", 
            duration: "5 min", 
            themeColor: Colors.blue,
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const MasteryDetailScreen(title: "Rainy Season Care", themeColor: Colors.blue))
            ),
          ),
          GuideCard(
            title: "Organic Compost", 
            duration: "12 min", 
            themeColor: Colors.green,
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const MasteryDetailScreen(title: "Organic Compost", themeColor: Colors.green))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTile(BuildContext context, IconData icon, String title, String sub) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ManagementSheet(
            title: title,
            steps: ManagementData.content[title] ?? [],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F4F1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF2D6A4F)),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ),
      ),
    );
  }
}