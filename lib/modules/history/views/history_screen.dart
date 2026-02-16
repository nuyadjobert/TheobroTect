import '../controllers/history_controller.dart';
import 'package:flutter/material.dart';
import '../widgets/history_card.dart';
import '../widgets/history_filter.dart';
import '../widgets/scan_details.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryController _controller = HistoryController();
  final TextEditingController _searchController = TextEditingController();

  // --- CONFIRMATION DIALOG LOGIC ---
  void _showDeleteDialog(int id, String? imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Delete Scan?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
          ),
          content: const Text(
            "This action cannot be undone. Do you want to remove this scan from your history?",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                final success = await _controller.deleteScan(id, imagePath);

                if (mounted && success) {
                  Navigator.pop(context);
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Scan deleted successfully"),
                      backgroundColor: Color(0xFF1B3022),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3022),
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
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          HistoryFilter(
            selectedFilter: _controller.activeFilter,
            onFilterSelected: (val) => setState(() => _controller.setActiveFilter(val)),
            selectedDate: _controller.selectedDate,
            onDateSelected: (date) => setState(() => _controller.setSelectedDate(date)),
          ),
          _buildSearchBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFDFB), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _controller.getHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1B3022)));
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final historyData = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
                      
                      final Map<String, dynamic> formattedData = {
                        "title": item['disease_key'].toString().replaceAll('_', ' ').toUpperCase(),
                        "date": item['created_at'], 
                        "confidence": (item['confidence'] * 100).toStringAsFixed(1),
                        "status": item['severity_key'] == 'default' ? 'Healthy' : 'Infected',
                        "image": item['image_path'], 
                        "isLocalFile": true, 
                      };

                      return HistoryCard(
                        data: formattedData,
                        onTap: () {
                          ScanDetailsSheet.show(context, formattedData);
                        },
                        onDelete: () => _showDeleteDialog(item['id'], item['image_path']),
                      );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No scans found", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}