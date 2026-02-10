  import 'package:flutter/material.dart';
import '../models/guide_model.dart';

class ManagementSheet extends StatefulWidget {
  final String title;
  final List<GuideStep> steps;

  const ManagementSheet({super.key, required this.title, required this.steps});

  @override
  State<ManagementSheet> createState() => _ManagementSheetState();
}

class _ManagementSheetState extends State<ManagementSheet> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox();
    
    final step = widget.steps[currentStep];
    final bool isLastStep = currentStep == widget.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / widget.steps.length,
            backgroundColor: Colors.grey.shade100,
            color: const Color(0xFF2D6A4F),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 32),
          // Step Icon
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFF0F4F1),
            child: Icon(step.icon, size: 36, color: const Color(0xFF2D6A4F)),
          ),
          const SizedBox(height: 24),
          Text("Step ${currentStep + 1}: ${step.title}", 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(step.description, textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 40),
          // Navigation Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (isLastStep) Navigator.pop(context);
                else setState(() => currentStep++);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isLastStep ? "Got it!" : "Next Step", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}