import 'package:flutter/material.dart';
import 'dart:ui';

class ScanResultScreen extends StatefulWidget {
  final String diseaseName;
  final double confidence;
  final String severity;

  const ScanResultScreen({
    super.key,
    this.diseaseName = "Black Pod Disease",
    this.confidence = 0.95,
    this.severity = "Severe",
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.severity == "Severe" ? const Color(0xFFE63946) : const Color(0xFF2D6A4F);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      // SafeArea prevents the image from blocking the Status Bar (Time, Battery, etc.)
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16), // Top margin
                  
                  // --- IMAGE CONTAINER (The Floating Card) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildHeroImage(),
                        
                        // Identification Line Overlay (Centered on the card)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.05),
                              child: CustomPaint(
                                size: const Size(180, 180), 
                                painter: DetectionAreaPainter(
                                  color: themeColor,
                                  pulseValue: _pulseController.value,
                                ),
                              ),
                            );
                          },
                        ),

                        // Detection Label anchored to the scan box
                        Positioned(
                          top: 50,
                          child: _buildDetectionLabel(themeColor),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DIAGNOSIS", style: TextStyle(color: themeColor, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(widget.diseaseName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                        const SizedBox(height: 20),
                        
                        _buildConfidenceMeter(themeColor),
                        
                        const SizedBox(height: 30),
                        const Text("Recommended Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildTaskTile(Icons.remove_circle_outline, "Isolate Pod", "Remove infected pods to stop spore spread.", themeColor),
                        _buildTaskTile(Icons.opacity, "Fungicide", "Apply copper-based spray to healthy pods.", Colors.blue),
                        
                        const SizedBox(height: 120), // Space for floating dock
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- TOP NAVIGATION ---
            Positioned(
              top: 25,
              left: 30,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            _buildFloatingDock(themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 320, // Reduced height for better balance
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/bp1.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetectionLabel(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Text(
        "${widget.diseaseName.toUpperCase()} DETECTED",
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConfidenceMeter(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Confidence Score", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
              Text("${(widget.confidence * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.w900, color: themeColor, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.confidence,
              backgroundColor: themeColor.withOpacity(0.1),
              color: themeColor,
              minHeight: 10,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskTile(IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black12),
      ),
    );
  }

  Widget _buildFloatingDock(Color themeColor) {
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332).withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    label: const Text("RE-SCAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(width: 1, height: 25, color: Colors.white24),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share, color: Colors.white, size: 20),
                    label: const Text("SHARE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetectionAreaPainter extends CustomPainter {
  final Color color;
  final double pulseValue;

  DetectionAreaPainter({required this.color, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 * (1 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 + (pulseValue * 10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    double cs = 30.0;

    path.moveTo(0, cs); path.lineTo(0, 0); path.lineTo(cs, 0);
    path.moveTo(size.width - cs, 0); path.lineTo(size.width, 0); path.lineTo(size.width, cs);
    path.moveTo(size.width, size.height - cs); path.lineTo(size.width, size.height); path.lineTo(size.width - cs, size.height);
    path.moveTo(cs, size.height); path.lineTo(0, size.height); path.lineTo(0, size.height - cs);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}