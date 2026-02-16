import 'package:flutter/material.dart';
import 'dart:io'; 

class ScanDetailsSheet {
  static void show(BuildContext context, Map<String, dynamic> data) {
    final String status = data['status'] ?? 'Healthy';
    final String diseaseName = data['title'] ?? 'Cacao Leaf';
    final bool isInfected = status == 'Infected';
    final Color statusColor = isInfected ? const Color(0xFFE63946) : const Color(0xFF2D6A4F);
    
    final bool isLocalFile = data['isLocalFile'] ?? false;
    final String imagePath = data['image'] ?? 'assets/placeholder.png';

    // 1. Get the dynamic treatment plan from the data map
    final String treatmentPlan = data['treatment'] ?? 
        (isInfected 
            ? "Remove affected leaves and consult an agricultural specialist for organic fungicide options." 
            : "Continue regular watering and ensure the plant receives adequate sunlight.");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1.6,
                        child: isLocalFile 
                          ? Image.file(
                              File(imagePath), 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  Image.asset('assets/placeholder.png', fit: BoxFit.cover),
                            )
                          : Image.asset(
                              imagePath, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  Image.asset('assets/placeholder.png', fit: BoxFit.cover),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. DIAGNOSTIC SUMMARY
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(26)),
                      ),
                      child: Row(
                        children: [
                          Icon(isInfected ? Icons.bug_report : Icons.check_circle, color: statusColor, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isInfected ? "DISEASE DETECTED" : "PLANT HEALTH",
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                                ),
                                Text(
                                  isInfected ? diseaseName : "Healthy Leaf",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. SCAN DATE
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Scanned on: ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        Text(data['date'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                    // 4. TREATMENT PLAN (REPLACED _buildStep WITH THIS)
                    Text(
                      isInfected ? "Treatment Plan" : "Maintenance Routine",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50], 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        treatmentPlan, // This displays your actual suggested treatment
                        style: TextStyle(
                          fontSize: 14, 
                          height: 1.5, 
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 5. DISMISS BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}