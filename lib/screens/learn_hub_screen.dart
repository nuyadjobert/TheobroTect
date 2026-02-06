import 'package:flutter/material.dart';
import '../widgets/learn/guide_card.dart';
import '../widgets/learn/prevention_tip_card.dart';

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 120,
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
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search farming techniques...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Daily Prevention Tip (The Enhanced Widget)
                  const Text("Prevention Tip", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B3022))),
                  const SizedBox(height: 16),
                  const PreventionTipCard(),
                  const SizedBox(height: 32),

                  // 2. Featured Guides (Horizontal)
                  const Text("Mastery Courses", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B3022))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        GuideCard(title: "Soil Fertility Secrets", duration: "8 min", themeColor: Colors.brown),
                        GuideCard(title: "Rainy Season Care", duration: "5 min", themeColor: Colors.blue),
                        GuideCard(title: "Organic Compost", duration: "12 min", themeColor: Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Management Topics (Vertical List Header)
                  const Text("Management Guides", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B3022))),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 4. Vertical List (Farm Maintenance instead of Disease Spotting)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildManagementTile(Icons.agriculture_rounded, "Optimizing Shade", "Learn how to balance sunlight for better yields."),
              _buildManagementTile(Icons.water_drop_outlined, "Smart Irrigation", "Water conservation during the dry season."),
              _buildManagementTile(Icons.inventory_2_outlined, "Storage Basics", "Keep beans dry and pest-free after harvest."),
              _buildManagementTile(Icons.handyman_outlined, "Tool Maintenance", "Sharpening and rust prevention for machetes."),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildManagementTile(IconData icon, String title, String sub) {
    return Container(
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
    );
  }
}