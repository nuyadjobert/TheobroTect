import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DiseaseDetailSheet extends StatefulWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailSheet({super.key, required this.disease});

  @override
  State<DiseaseDetailSheet> createState() => _DiseaseDetailSheetState();
}

class _DiseaseDetailSheetState extends State<DiseaseDetailSheet> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool isTagalog = false;

  final Color _primaryGreen = const Color(0xFF2D6A4F);
  final Color _lightMint = const Color(0xFFD8F3DC);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    final List<String> images = List<String>.from(
      widget.disease["images"] ?? [],
    );

    if (images.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < images.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? AppColors.nightCard : Colors.white;
    final dragHandleColor = isDark ? Colors.white24 : Colors.grey[300];
    final titleColor = isDark ? Colors.white : const Color(0xFF1B4332);

    final toggleBg = isDark ? _primaryGreen.withAlpha(45) : _lightMint;
    final toggleBorder = isDark
        ? _primaryGreen.withAlpha(110)
        : _primaryGreen.withAlpha(51);
    final toggleUnselectedText = isDark ? Colors.white70 : _primaryGreen;

    final originBg = isDark
        ? Colors.orange.withAlpha(38)
        : Colors.orange.withAlpha(26);
    final originBorder = Colors.orange.withAlpha(isDark ? 100 : 77);
    final originTextColor = isDark ? Colors.orange[200]! : Colors.deepOrange;

    final sectionHeaderColor = isDark ? Colors.white70 : Colors.grey[800];

    final descriptionBoxBg =
        isDark ? AppColors.nightBg : const Color(0xFFF8F9FA);
    final descriptionTextColor = isDark ? Colors.white70 : Colors.grey[700];

    final symptomCardBg = isDark ? AppColors.nightBg : Colors.white;
    final symptomCardBorder =
        isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final symptomCardShadow =
        isDark ? Colors.black.withAlpha(60) : Colors.grey.withAlpha(33);
    final symptomIconBg = isDark ? _primaryGreen.withAlpha(45) : _lightMint;
    final symptomTextColor =
        isDark ? Colors.white70 : const Color(0xFF4A4A4A);

    final List<String> diseaseImages = List<String>.from(
      widget.disease["images"] ?? [],
    );

    final String description = isTagalog
        ? (widget.disease["tagalog"]?["description"] ??
              widget.disease["description"])
        : widget.disease["description"];

    final List<String> symptoms = isTagalog
        ? List<String>.from(
            widget.disease["tagalog"]?["symptoms"] ??
                widget.disease["symptoms"],
          )
        : List<String>.from(widget.disease["symptoms"]);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? 10 : 0,
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 10),
                height: 5,
                width: 45,
                decoration: BoxDecoration(
                  color: dragHandleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGreen.withAlpha(38),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: diseaseImages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) =>
                          Image.asset(diseaseImages[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(102),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(diseaseImages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: _currentPage == index ? 16 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withAlpha(128),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.disease["title"] ?? "Unknown",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => isTagalog = !isTagalog),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: toggleBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: toggleBorder),
                            ),
                            child: Row(
                              children: [
                                _buildToggleOption(
                                  "EN",
                                  !isTagalog,
                                  toggleUnselectedText,
                                ),
                                _buildToggleOption(
                                  "PH",
                                  isTagalog,
                                  toggleUnselectedText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: originBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: originBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: originTextColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Origin: ${widget.disease["origin"] ?? "Unknown"}",
                            style: TextStyle(
                              color: originTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      isTagalog ? "Paglalarawan" : "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sectionHeaderColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: descriptionBoxBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          color: descriptionTextColor,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      isTagalog ? "Mga Sintomas" : "Common Symptoms",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sectionHeaderColor,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ...symptoms.map(
                      (symptom) => _buildSymptomCard(
                        symptom,
                        symptomCardBg,
                        symptomCardBorder,
                        symptomCardShadow,
                        symptomIconBg,
                        symptomTextColor,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _primaryGreen.withAlpha(102),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isTagalog ? "Naintindidihan Ko" : "I Acknowledge",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String text,
    bool isSelected,
    Color unselectedTextColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? _primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4)]
            : [],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : unselectedTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomCard(
    String text,
    Color cardBg,
    Color cardBorder,
    Color cardShadow,
    Color iconBg,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: _primaryGreen, size: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}