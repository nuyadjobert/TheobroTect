import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/scan_result_controller.dart';

class RecommendationsPanel extends StatefulWidget {
  final ScanResultController controller;
  final String lang; 

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
  late String _activeLang; // Local state to handle the translation toggle

  @override
  void initState() {
    super.initState();
    _activeLang = widget.lang; // Initialize with the passed language
  }

  // Meta data updated with Tagalog labels for the Chips
  static const _sectionMeta = <String, ({String labelEn, String labelTl, IconData icon, Color color})>{
    "what_to_do_now": (
      labelEn: "What to do now",
      labelTl: "Dapat gawin",
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFB300),
    ),
    "prevention": (
      labelEn: "Prevention",
      labelTl: "Pag-iwas",
      icon: Icons.shield_outlined,
      color: Color(0xFF4CAF50),
    ),
    "when_to_escalate": (
      labelEn: "When to escalate",
      labelTl: "Kailan magsusuri",
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFE53935),
    ),
  };

  List<String> _itemsForSection() {
    final c = widget.controller;
    final isTl = _activeLang == "tl";

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
                  _activeLang == "tl" ? "Rekomendasyon #${index + 1}" : "Recommendation #${index + 1}",
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
            // --- HEADER WITH TRANSLATOR TOGGLE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _activeLang == "tl" ? "Mga Hakbang" : "Action Steps",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
                ),
                _buildLanguageToggle(),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECTION SELECTION (CHIPS) ---
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              _activeLang == "tl" ? e.value.labelTl : e.value.labelEn,
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
            
            // --- LIST OF RECOMMENDATIONS ---
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No recommendations found.",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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
                  return _buildRecommendationCard(text, index);
                },
              ),
          ],
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  // --- ENHANCED GREEN TOGGLE ---
  Widget _buildLanguageToggle() {
    return Container(
      height: 40,
      width: 110, // Fixed width for a balanced look
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Very light mint green background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1), // Soft green border
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleBtn("EN", _activeLang == "en")),
          Expanded(child: _buildToggleBtn("TL", _activeLang == "tl")),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.mediumImpact();
          setState(() => _activeLang = label.toLowerCase());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          // Active state is a rich forest green, Inactive is transparent
          color: isSelected ? const Color(0xFF2D6A4F) : Colors.transparent, 
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: const Color(0xFF2D6A4F).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] 
            : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            // White text for active green, Dark green for inactive mint
            color: isSelected ? Colors.white : const Color(0xFF2D6A4F),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String text, int index) {
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
  }
}