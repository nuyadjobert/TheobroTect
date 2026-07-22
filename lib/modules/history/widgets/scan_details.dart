import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../controllers/scan_result_controller.dart';
import '../../scan/widgets/treatment_plan_section.dart';

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
  String _activeLang = "en";

  // Refined Color Palette
  static const Color forestGreen = Color(0xFF1B3022);
  static const Color leafGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFFBFBF9); // Slightly cleaner cream
  static const Color dangerRed = Color(0xFFD9534F); // For infections

  String _formatDate(String? rawDate) {
    if (rawDate == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('MMMM dd, yyyy').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final bool isInfected = widget.data['status'] == 'Infected';
        final c = widget.controller;
        final lang = _activeLang;
        
        final String title = c.displayName[lang] ?? widget.data['title'] ?? (isInfected ? "Detected Infection" : "Healthy Leaf");
        final String imagePath = widget.data['image'] ?? '';
        final bool isLocal = widget.data['isLocalFile'] ?? false;
        final String desc = c.description[lang] ?? '';

        return Container(
          height: MediaQuery.of(context).size.height * 0.92, // Slightly taller
          decoration: const BoxDecoration(
            color: creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // --- DRAG HANDLE ---
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(15),
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- IMAGE ---
                      _buildImageFrame(imagePath, isLocal),
                      const SizedBox(height: 24),

                      // --- BADGE & LANG TOGGLE ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(isInfected),
                          _buildLanguageToggle(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- TITLE & DATE ---
                      Text(
                        title, 
                        style: const TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.w800, 
                          color: forestGreen, 
                          height: 1.1,
                          letterSpacing: -0.5
                        )
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            "Scanned on ${_formatDate(widget.data['date'])}", 
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: 13, 
                              fontWeight: FontWeight.w500
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- DESCRIPTION CARD ---
                      if (desc.isNotEmpty) _buildDescriptionCard(desc),

                      const SizedBox(height: 24),

                      // --- TREATMENT PLAN ---
                      TreatmentPlanSection(
                        recommendations: c.recommendations,
                        lang: lang,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), 
            blurRadius: 24, 
            offset: const Offset(0, 12)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: path.isEmpty
              ? Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                )
              : isLocal
                  ? Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _errorImage(),
                    )
                  : Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 48),
    );
  }

  Widget _buildStatusBadge(bool isInfected) {
    final Color badgeColor = isInfected ? dangerRed : leafGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(200), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInfected ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            isInfected ? "INFECTION DETECTED" : "HEALTHY",
            style: TextStyle(
              color: badgeColor, 
              fontSize: 11, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 0.5
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(2), blurRadius: 4, offset: const Offset(0, 2))
        ]
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? forestGreen : Colors.transparent, 
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text(l, style: TextStyle(
                color: active ? Colors.white : Colors.grey[600], 
                fontSize: 12, 
                fontWeight: active ? FontWeight.bold : FontWeight.w600
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionCard(String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(2), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: leafGreen),
              const SizedBox(width: 8),
              Text(
                _activeLang == "tl" ? "Tungkol sa Kondisyong Ito" : "About this Condition",
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold, 
                  color: forestGreen, 
                  letterSpacing: 0.2
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc, 
            style: TextStyle(
              fontSize: 14.5, 
              height: 1.6, 
              color: Colors.grey[700], 
              fontWeight: FontWeight.w400
            )
          ),
        ],
      ),
    );
  }

}