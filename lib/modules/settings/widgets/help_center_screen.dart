import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF1B3022)),
        title: const Text(
          "Help Center",
          style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1B3022)
            ),
          ),
          const SizedBox(height: 20),
          
          // Pass 'context' into each tile method
          _buildFaqTile(
            context,
            "How do I scan a cacao leaf?", 
            "Navigate to the 'Scan' tab. Position the cacao leaf within the frame and ensure there is enough light. The AI will analyze the leaf for signs of disease."
          ),
          _buildFaqTile(
            context,
            "What is 'Mastery Rating'?", 
            "Your Mastery Rating increases as you complete lessons in the 'Learn' section. It tracks your progress toward becoming a cacao farming expert."
          ),
          _buildFaqTile(
            context,
            "Is my data private?", 
            "Yes, your scan history and profile information are stored securely and are only used to provide you with better farming insights."
          ),
          _buildFaqTile(
            context,
            "How to contact support?", 
            "For technical issues, you can reach the developers via the 'About' section or email support@theobrotect.ph."
          ),
          
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Still need help? Contact your local coordinator.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Added BuildContext context to the parameters
  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDE8)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF2D6A4F),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 15, 
              color: Color(0xFF1B3022)
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}