import 'package:flutter/material.dart';
import '../widgets/guide_card.dart';
import '../widgets/prevention_tip_card.dart';
import '../widgets/management_sheet.dart';
import '../widgets/mastery_detail_screen.dart';
import '../models/guide_model.dart';

class _GuideCategory {
  final IconData icon;
  final String label; // short text shown under the circle icon
  final String lookupKey; // key into ManagementData.content
  final Color bg;

  const _GuideCategory({
    required this.icon,
    required this.label,
    required this.lookupKey,
    required this.bg,
  });
}

// Represents one Mastery Course card.
class _MasteryCourse {
  final String title;
  final String duration;
  final Color themeColor;
  final String imageUrl;
  final String rating;
  final String enrollment;

  const _MasteryCourse({
    required this.title,
    required this.duration,
    required this.themeColor,
    required this.imageUrl,
    required this.rating,
    required this.enrollment,
  });
}

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  // Full set of Management Guide categories. Only the first 3 show in the
  // compact row; "View all" reveals the complete list.
  static const List<_GuideCategory> _allCategories = [
    _GuideCategory(
      icon: Icons.agriculture_rounded,
      label: "Shade Mgmt",
      lookupKey: "Optimizing Shade",
      bg: Color(0xFFDCEDE1),
    ),
    _GuideCategory(
      icon: Icons.water_drop_outlined,
      label: "Irrigation",
      lookupKey: "Smart Irrigation",
      bg: Color(0xFFDCEAF7),
    ),
    _GuideCategory(
      icon: Icons.handyman_outlined,
      label: "Tool Care",
      lookupKey: "Tool Maintenance",
      bg: Color(0xFFFBE6D4),
    ),
    _GuideCategory(
      icon: Icons.inventory_2_outlined,
      label: "Storage",
      lookupKey: "Storage Basics",
      bg: Color(0xFFF3E5F5),
    ),
  ];

  // Full set of Mastery Courses. Image keywords are chosen to match each
  // title (e.g. rain/crops for "Rainy Season Care") using LoremFlickr's
  // tag-based photo endpoint: https://loremflickr.com/{w}/{h}/{tags}
  static const List<_MasteryCourse> _allCourses = [
    _MasteryCourse(
      title: "Soil Fertility Secrets",
      duration: "8 min",
      themeColor: Colors.brown,
      imageUrl: "https://loremflickr.com/400/300/soil,fertility,farm",
      rating: "4.8",
      enrollment: "65",
    ),
    _MasteryCourse(
      title: "Rainy Season Care",
      duration: "5 min",
      themeColor: Colors.blue,
      imageUrl: "https://loremflickr.com/400/300/rain,crops,field",
      rating: "4.7",
      enrollment: "40",
    ),
    _MasteryCourse(
      title: "Organic Compost",
      duration: "12 min",
      themeColor: Colors.green,
      imageUrl: "https://loremflickr.com/400/300/compost,organic,farm",
      rating: "4.9",
      enrollment: "112",
    ),
  ];

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
                  style: TextStyle(
                      color: Color(0xFF1B3022),
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // --> Sterilize Pruning Tools ----
                  const PreventionTipCard(
                    label: "TODAY'S ACTION",
                    message:
                        "Sterilize your pruning tools before moving between trees.",
                    icon: Icons.sanitizer_rounded,
                  ),
                  const SizedBox(height: 32),

                  //  -> "Management Guides" ----
                  _buildSectionHeader(
                    context,
                    title: "Management Guides",
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryRow(context),
                  const SizedBox(height: 32),

                  // "Mastery Courses" ----
                  _buildSectionHeader(
                    context,
                    title: "Mastery Courses",
                    onViewAll: () => _showAllCourses(context),
                  ),
                  const SizedBox(height: 16),
                  _buildHorizontalGuides(context),
                  const SizedBox(height: 10),
                  Text(
                    "${_allCourses.length} courses available",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // "View all" for Management Guides -> bottom sheet listing every category
  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "All Management Guides",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._allCategories.map((category) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: category.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon,
                          color: const Color(0xFF2D6A4F), size: 20),
                    ),
                    title: Text(
                      category.lookupKey,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(sheetContext); // close the list first
                      _openGuideSheet(context, category);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // "View all" for Mastery Courses -> bottom sheet with a scrollable grid
  void _showAllCourses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Mastery Courses (${_allCourses.length})",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: GridView.builder(
                    itemCount: _allCourses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final course = _allCourses[index];
                      return GuideCard(
                        title: course.title,
                        duration: course.duration,
                        themeColor: course.themeColor,
                        imageUrl: course.imageUrl,
                        rating: course.rating,
                        enrollment: course.enrollment,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MasteryDetailScreen(
                                title: course.title,
                                themeColor: course.themeColor,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openGuideSheet(BuildContext context, _GuideCategory category) {
    final steps = ManagementData.content[category.lookupKey] ?? [];
    if (steps.isEmpty) {
      debugPrint(
          'No ManagementData.content found for key "${category.lookupKey}"');
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManagementSheet(
        title: category.lookupKey,
        steps: steps,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B3022),
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: const [
                Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B8F71),
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 16, color: Color(0xFF6B8F71)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == _allCategories.length - 1 ? 0 : 16,
            ),
            child: GestureDetector(
              onTap: () => _openGuideSheet(context, category),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: category.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(category.icon,
                        color: const Color(0xFF2D6A4F), size: 32),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B3022),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Mastery Courses -> horizontal scroll using your real GuideCard
  Widget _buildHorizontalGuides(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allCourses.length,
        itemBuilder: (context, index) {
          final course = _allCourses[index];
          return GuideCard(
            title: course.title,
            duration: course.duration,
            themeColor: course.themeColor,
            imageUrl: course.imageUrl,
            rating: course.rating,
            enrollment: course.enrollment,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MasteryDetailScreen(
                  title: course.title,
                  themeColor: course.themeColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
