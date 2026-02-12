import 'package:flutter/material.dart';
import '../widgets/history_card.dart';
import '../widgets/history_filter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 1. State Variables for Filtering
  String _activeFilter = "All Scans";
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  // Your Data Source
  final List<Map<String, dynamic>> _historyItems = [
    {"title": "Black Pod Rot", "date": "Feb 3, 2026", "confidence": "88.0", "status": "Infected", "image": "assets/images/bp1.png"},
    {"title": "Healthy Pod", "date": "Feb 3, 2026", "confidence": "99.0", "status": "Healthy", "image": "assets/images/img1.png"},
    {"title": "Black Pod", "date": "Feb 3, 2026", "confidence": "99.0", "status": "Infected", "image": "assets/images/bp2.png"},
    {"title": "Mealybug", "date": "Feb 3, 2026", "confidence": "95.0", "status": "Infected", "image": "assets/images/mb1.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3022), // Dark green background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Scan History", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 24
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Future sorting logic
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // 2. Updated Filter Section (Status + Date)
          HistoryFilter(
            selectedFilter: _activeFilter,
            onFilterSelected: (val) => setState(() => _activeFilter = val),
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
          ),
          
          _buildSearchBar(),
          
          // 3. Main Content Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFDFB), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.68, // Keeps cards tall enough to prevent overflow
                ),
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  return HistoryCard(
                    data: _historyItems[index],
                    onTap: () {
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Search scans...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.mic, color: Colors.grey),
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }
}