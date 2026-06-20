import 'dart:io';
import 'package:flutter/material.dart';

class ScanResultHeader extends StatelessWidget {
  final String? imagePath;

  const ScanResultHeader({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'scan_image',
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: imagePath != null
              ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover)
              : const DecorationImage(
                  image: AssetImage('assets/images/bp1.png'),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}