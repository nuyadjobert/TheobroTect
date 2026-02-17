import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../controllers/scan_result_controller.dart'; 

class ScanDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  final ScanResultController controller;

  const ScanDetailsSheet({
    super.key,
    required this.data,
    required this.controller,
  });

  static void show(BuildContext context, Map<String, dynamic> data, ScanResultController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanDetailsSheet(data: data, controller: controller),
    );
  }

  @override
  State<ScanDetailsSheet> createState() => _ScanDetailsSheetState();
}

class _ScanDetailsSheetState extends State<ScanDetailsSheet> {
  String _selectedSection = "what_to_do_now";
  String _activeLang = "en"; // Local state for the toggle

  // Nature-Tech Palette
  static const Color forestGreen = Color(0xFF1B3022);
  static const Color leafGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF9F9F5);

  // Synced Section Meta
  static const _sectionMeta = <String, ({String labelEn, String labelTl, IconData icon})>{
    "what_to_do_now": (
      labelEn: "What to do now",
      labelTl: "Dapat gawin",
      icon: Icons.bolt_rounded,
    ),
    "prevention": (
      labelEn: "Prevention",
      labelTl: "Pag-iwas",
      icon: Icons.shield_outlined,
    ),
    "when_to_escalate": (
      labelEn: "When to escalate",
      labelTl: "Kailan magsusuri",
      icon: Icons.warning_amber_rounded,
    ),
  };

  String _formatDate(String? rawDate) {
    if (rawDate == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  List<String> _getItems() {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final bool isInfected = widget.data['status'] == 'Infected';
        final String title = widget.data['title'] ?? (isInfected ? "Detected Infection" : "Healthy Leaf");
        final String imagePath = widget.data['image'] ?? '';
        final bool isLocal = widget.data['isLocalFile'] ?? false;
        final items = _getItems();

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageFrame(imagePath, isLocal),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(isInfected),
                          Text("Date Scanned: ${_formatDate(widget.data['date'])}", 
                              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(title, 
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: forestGreen, letterSpacing: -0.5)),
                          ),
                          _buildLanguageToggle(),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(_activeLang == "tl" ? "Gabay sa Pag-aalaga" : "Care Guide", 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: forestGreen)),
                      const SizedBox(height: 12),
                      
                      _buildSectionTabs(),
                      const SizedBox(height: 20),

                      if (items.isEmpty)
                        Center(child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(_activeLang == "tl" ? "Walang makitang hakbang." : "No specific steps found.", 
                              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildInstructionCard(items[index], index + 1),
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildActionButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildImageFrame(String path, bool isLocal) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: isLocal 
              ? Image.file(File(path), fit: BoxFit.cover) 
              : Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isInfected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: forestGreen, borderRadius: BorderRadius.circular(8)),
      child: Text(
        isInfected ? "ANALYSIS: DETECTED" : "ANALYSIS: HEALTHY",
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: ["EN", "TL"].map((l) {
          bool active = _activeLang == l.toLowerCase();
          return GestureDetector(
            onTap: () {
               HapticFeedback.lightImpact();
               setState(() => _activeLang = l.toLowerCase());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? leafGreen : Colors.transparent, 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(l, style: TextStyle(
                color: active ? Colors.white : leafGreen, 
                fontSize: 11, 
                fontWeight: FontWeight.bold
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _sectionMeta.entries.map((e) {
          bool selected = _selectedSection == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedSection = e.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? forestGreen : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(e.value.icon, size: 16, color: selected ? Colors.white : Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      _activeLang == "tl" ? e.value.labelTl : e.value.labelEn,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black54, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionCard(String text, int number) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9), 
              borderRadius: BorderRadius.circular(8)
            ),
            alignment: Alignment.center,
            child: Text("$number", style: const TextStyle(color: leafGreen, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: forestGreen, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text("Return to Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}