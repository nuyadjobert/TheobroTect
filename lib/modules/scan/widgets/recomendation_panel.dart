import 'package:flutter/material.dart';
import '../controllers/scan_result_controller.dart';

class RecommendationsPanel extends StatefulWidget {
  final ScanResultController controller;
  final String lang; // or "tl"

  const RecommendationsPanel({
    super.key,
    required this.controller,
    required this.lang,
  });

  @override
  State<RecommendationsPanel> createState() => _RecommendationsPanelState();
}

class _RecommendationsPanelState extends State<RecommendationsPanel> {
  String _selectedSection = "what_to_do_now";

  static const _sectionMeta = <String, ({String label, IconData icon})>{
    "what_to_do_now": (label: "What to do now", icon: Icons.bolt_rounded),
    "prevention": (label: "Prevention", icon: Icons.shield_outlined),
    "when_to_escalate": (label: "When to escalate", icon: Icons.warning_amber_rounded),
  };

  List<String> _itemsForSection() {
    final c = widget.controller;
    final isTl = widget.lang == "tl";

    switch (_selectedSection) {
      case "what_to_do_now":
        return isTl ? c.whatToDoNowTl : c.whatToDoNowEn;
      case "prevention":
        return isTl ? c.preventionTl : c.preventionEn;
      case "when_to_escalate":
        return isTl ? c.whenToEscalateTl : c.whenToEscalateEn;
      default:
        return const [];
    }
  }

  void _showItemDetail(String text, int index) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recommendation #${index + 1}",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _sectionMeta.entries.map((e) {
            final isSelected = _selectedSection == e.key;
            return ChoiceChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.value.icon, size: 18),
                  const SizedBox(width: 8),
                  Text(e.value.label),
                ],
              ),
              onSelected: (_) => setState(() => _selectedSection = e.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Text("No recommendations found.")
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final text = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showItemDetail(text, index),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, child: Text("${index + 1}")),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text)),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
