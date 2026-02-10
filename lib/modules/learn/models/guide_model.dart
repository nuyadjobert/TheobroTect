import 'package:flutter/material.dart';

class GuideStep {
  final String title;
  final String description;
  final IconData icon;

  GuideStep({required this.title, required this.description, required this.icon});
}

class ManagementData {
  static final Map<String, List<GuideStep>> content = {
    "Optimizing Shade": [
      GuideStep(title: "Assess Light", icon: Icons.wb_sunny, description: "Check if leaves are pale (too much sun) or dark and drooping (too little)."),
      GuideStep(title: "Select Mesh", icon: Icons.grid_4x4, description: "Use 30% mesh for grains and 50-70% for leafy greens."),
      GuideStep(title: "Check Height", icon: Icons.height, description: "Ensure the shade is at least 6 feet high for air circulation."),
    ],
    "Smart Irrigation": [
      GuideStep(title: "Soil Test", icon: Icons.fingerprint, description: "Stick your finger 2 inches into soil. If dry, it's time to water."),
      GuideStep(title: "Time it Right", icon: Icons.timer_outlined, description: "Water between 5 AM and 9 AM to reduce evaporation."),
      GuideStep(title: "Root Focus", icon: Icons.water_drop, description: "Apply water directly to the base, not the leaves."),
    ],
    "Storage Basics": [
      GuideStep(title: "Dry Thoroughly", icon: Icons.wb_sunny_outlined, description: "Ensure crops are below 12% moisture to prevent mold."),
      GuideStep(title: "Airtight Seal", icon: Icons.inventory_2, description: "Use hermetic bags to suffocate potential pests."),
      GuideStep(title: "Elevate", icon: Icons.layers, description: "Keep bags on pallets 10cm off the ground."),
    ],
    "Tool Maintenance": [
      GuideStep(title: "Clean After Use", icon: Icons.cleaning_services, description: "Remove sap and soil with a wire brush."),
      GuideStep(title: "Sharpening", icon: Icons.architecture, description: "Use a whetstone at a 20-degree angle for blades."),
      GuideStep(title: "Oil Coating", icon: Icons.oil_barrel, description: "Wipe metal with vegetable oil to prevent rust."),
    ],
  };
}