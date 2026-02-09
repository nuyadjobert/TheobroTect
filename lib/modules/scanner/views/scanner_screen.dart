import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:permission_handler/permission_handler.dart';
import '../../scan/views/scan_result_screen.dart'; // Ensure this file exists with the code provided earlier

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isAnalyzing = false; 
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupCamera();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _setupCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isPermissionGranted = true;
          });
        }
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  // --- TRIGGER SCANNING LOGIC ---
  Future<void> _handleCapture() async {
    if (_isAnalyzing) return;

    HapticFeedback.heavyImpact();
    
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI processing time (e.g., sending image to TFLite/Cloud)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to the Result Screen we created earlier
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScanResultScreen(
            diseaseName: "Black Pod Disease",
            confidence: 0.95,
            severity: "Severe",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: CameraPreview(_controller!),
          ),

          // 2. Dark Overlay with "Cutout"
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white, // This creates the "hole"
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Scanning Animation & Corner Brackets
          Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * 280,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildCorner(top: 0, left: 0),
                  _buildCorner(top: 0, right: 0),
                  _buildCorner(bottom: 0, left: 0),
                  _buildCorner(bottom: 0, right: 0),
                ],
              ),
            ),
          ),

          // 4. UI Controls
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildGlassIconButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.yellow : Colors.white,
                        onTap: _toggleFlash,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Align cocoa pod within frame",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Capture Button
                GestureDetector(
                  onTap: _handleCapture,
                  child: Container(
                    height: 84,
                    width: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),

          // 5. ANALYSIS OVERLAY (Shows when _isAnalyzing is true)
          if (_isAnalyzing)
            Container(
              color: Colors.black87,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.greenAccent),
                  const SizedBox(height: 20),
                  const Text(
                    "ANALYZING POD...",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Identifying disease patterns",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: (top != null && left != null) ? const Radius.circular(16) : Radius.zero,
            topRight: (top != null && right != null) ? const Radius.circular(16) : Radius.zero,
            bottomLeft: (bottom != null && left != null) ? const Radius.circular(16) : Radius.zero,
            bottomRight: (bottom != null && right != null) ? const Radius.circular(16) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}