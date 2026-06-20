import 'package:flutter/material.dart';
import '../model/recommendation_item.dart';
class TreatmentPlanSection extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TreatmentPlanSection({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Treatment Plan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3022),
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => _RecommendationBlock(rec: rec)),
      ],
    );
  }
}

class _RecommendationBlock extends StatelessWidget {
  final RecommendationItem rec;

  const _RecommendationBlock({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.category,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          ...rec.content.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text("• $item"),
            ),
          ),
        ],
      ),
    );
  }
}