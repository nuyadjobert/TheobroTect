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

  // Added colors to the meta for dynamic theme matching
  static const _sectionMeta = <String, ({String label, IconData icon, Color color})>{
    "what_to_do_now": (
      label: "What to do now",
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFB300), // Amber
    ),
    "prevention": (
      label: "Prevention",
      icon: Icons.shield_outlined,
      color: Color(0xFF4CAF50), // Green
    ),
    "when_to_escalate": (
      label: "When to escalate",
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFE53935), // Red
    ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_sectionMeta[_selectedSection]!.icon, 
                     color: _sectionMeta[_selectedSection]!.color),
                const SizedBox(width: 8),
                Text(
                  "Recommendation #${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3022),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final items = _itemsForSection();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Selection (Chips) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sectionMeta.entries.map((e) {
                  final isSelected = _selectedSection == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      pressElevation: 0,
                      selectedColor: const Color(0xFF1B3022),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              e.value.icon,
                              size: 18,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e.value.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedSection = e.key),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- List of Recommendations ---
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No recommendations found.",
                    style: TextStyle(color: Colors.grey, fontStyle:FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final text = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showItemDetail(text, index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Number Badge
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F8E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Color(0xFF2D6A4F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Instruction Text
                              Expanded(
                                child: Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF2E3E33),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}