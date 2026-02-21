import 'package:flutter/material.dart';

class DiseaseSlider extends StatefulWidget {
  final List<Map<String, dynamic>> diseaseData;
  final Function(int) onDiseaseTap;

  const DiseaseSlider({
    super.key,
    required this.diseaseData,
    required this.onDiseaseTap,
  });

  @override
  State<DiseaseSlider> createState() => _DiseaseSliderState();
}

class _DiseaseSliderState extends State<DiseaseSlider> {
  late PageController _pageController;
  // Start tracking from index 1 (the 2nd image)
  int _activePage = 1;

  @override
  void initState() {
    super.initState();
    // initialPage: 1 makes the 2nd card the center on opening
    // viewportFraction 0.82-0.85 ensures side cards are partially visible
    _pageController = PageController(
      viewportFraction: 0.82, 
      initialPage: 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200, // Adjusted for a cleaner rectangular profile
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.diseaseData.length,
            onPageChanged: (int index) {
              setState(() => _activePage = index);
            },
            itemBuilder: (context, index) {
              return _buildRectangleCard(index);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildRectangleCard(int index) {
    bool isActive = index == _activePage;

    return GestureDetector(
      onTap: () => widget.onDiseaseTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          // Side cards shrink slightly vertically to emphasize the center card
          vertical: isActive ? 0 : 12, 
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Less rounding for a "rectangular" look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isActive ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              Image.asset(
                widget.diseaseData[index]["image"]!,
                fit: BoxFit.cover,
              ),
              
              // 2. Linear Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // 3. Top Label (Optional - kept for context)
              Positioned(
                top: 12,
                right: 12,
                child: _buildBadge(),
              ),

              // 4. Information Layer
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.diseaseData[index]["title"]!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.diseaseData[index]["origin"] ?? "Global",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), 
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: const Text(
        "COMMON",
        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.diseaseData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: _activePage == index ? 18 : 6,
          decoration: BoxDecoration(
            color: _activePage == index ? Colors.green : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}