import 'package:flutter/material.dart';
import '../../scan/views/scanner_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for multiple notifications
    final List<Map<String, String>> alerts = [
      {
        "id": "POD-001",
        "disease": "Cacao Pod Borer",
        "severity": "High",
        "date": "Apr 18 • 02:45 PM",
        "sector": "Sector B"
      },
      {
        "id": "POD-042",
        "disease": "Black Pod Rot",
        "severity": "Moderate",
        "date": "Apr 18 • 01:20 PM",
        "sector": "Sector A"
      },
      {
        "id": "POD-089",
        "disease": "Mealybug",
        "severity": "Low",
        "date": "Apr 17 • 09:15 AM",
        "sector": "Sector C"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Active Alerts",
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return _buildNotificationCard(context, alert);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, String> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert['id']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    _buildSeverityBadge(alert['severity']!),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  alert['disease']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Location: ${alert['sector']} • ${alert['date']}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons Divider
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          
          // Row of Buttons
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Logic to remove/ignore this specific notification
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: Text(
                      "IGNORE",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                VerticalDivider(color: Colors.white.withOpacity(0.1), width: 1, indent: 10, endIndent: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScannerScreen()),
                      );
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "RE-SCAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'high':
        color = Colors.redAccent;
        break;
      case 'moderate':
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.lightBlueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}