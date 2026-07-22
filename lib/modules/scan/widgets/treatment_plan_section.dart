import 'package:flutter/material.dart';
import '../model/recommendation_item.dart';

class TreatmentPlanSection extends StatelessWidget {
  final List<RecommendationItem> recommendations;
  final String lang;

  const TreatmentPlanSection({
    super.key,
    required this.recommendations,
    this.lang = 'tl',
  });

  static const Map<String, Map<String, String>> categoryTitles = {
    'action_items': {
      'en': 'Recommended Actions',
      'tl': 'Mga Inirerekomendang Hakbang',
    },
    'prevention_items': {
      'en': 'Prevention Tips',
      'tl': 'Mga Paraan ng Pag-iwas',
    },
    'escalate_txt': {
      'en': 'When to Seek Expert Help',
      'tl': 'Kailan Dapat Humingi ng Tulong',
    },
  };

  static String getCategoryTitle(String category, String language) {
    return categoryTitles[category]?[language] ?? category.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            lang == 'tl' ? "Plano ng Paggamot" : "Treatment Plan",
            style: const TextStyle(
              fontSize: 22, // Slightly larger for better hierarchy
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B3022),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...recommendations.map((rec) => _RecommendationBlock(rec: rec, lang: lang)),
      ],
    );
  }
}

class _RecommendationBlock extends StatelessWidget {
  final RecommendationItem rec;
  final String lang;

  const _RecommendationBlock({required this.rec, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 1. Soft base color (Crucial for claymorphism)
        color: const Color(0xFFF0F4F1), 
        // 2. Large, friendly border radius
        borderRadius: BorderRadius.circular(24),
        // 3. Subtle inner border to simulate the 3D edge highlight
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        // 4. The Clay Shadows (One dark bottom-right, one white top-left)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
          Text(
            TreatmentPlanSection.getCategoryTitle(
              rec.category,
              lang,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF2A4D35), // Darker green for contrast
            ),
          ),
          const SizedBox(height: 12),
          
          // Bullet Points (Upgraded to stylish rows)
          ...rec.content(lang).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom clay-like bullet point
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 12),
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  // Text
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5, // Better readability
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}