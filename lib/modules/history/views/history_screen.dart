import '../controllers/history_controller.dart';
import 'package:flutter/material.dart';
import '../widgets/history_card.dart';
import '../widgets/history_filter.dart';
import '../widgets/scan_details.dart';
import '../controllers/scan_result_controller.dart';
import '../../../core/sync/sync_trigger.dart';
import '../widgets/empty_state.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryController _controller = HistoryController();
  final TextEditingController _searchController = TextEditingController();
  final ScanResultController _scanResultController = ScanResultController(
    diseaseName: "Unknown",
    confidence: 0.0,
    severity: "default",
  );
  bool _isSyncing = false;
  final SyncTrigger _syncTrigger = SyncTrigger();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Header stays forest-dark in both modes — it's already dark themed.
    final headerBg = AppColors.forestDark;
    final contentBg = isDark ? AppColors.nightBg : const Color(0xFFFBFDFB);
    final searchFill = isDark ? AppColors.nightCard : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.forestDark;
    final textSecondary = isDark ? Colors.white60 : Colors.grey[500];
    final hintColor = isDark ? Colors.white38 : Colors.grey[400];
    final iconMuted = isDark ? Colors.white54 : Colors.grey;
    final progressColor = isDark ? AppColors.forestLight : AppColors.forestDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light, // white icons, since header bg is dark green
        systemNavigationBarColor: contentBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: headerBg,
        appBar: AppBar(
          backgroundColor: headerBg,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "Scan History",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              HistoryFilter(
                selectedFilter: _controller.activeFilter,
                onFilterSelected: (val) =>
                    setState(() => _controller.setActiveFilter(val)),
                selectedDate: _controller.selectedDate,
                onDateSelected: (date) =>
                    setState(() => _controller.setSelectedDate(date)),
              ),
              _buildSearchBar(searchFill, textPrimary, hintColor, iconMuted),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: contentBg,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _controller.getHistory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: progressColor,
                          ),
                        );
                      }

                      final rawData = snapshot.data ?? [];
                      final filteredData = rawData.where((item) {
                        final searchText = _searchController.text.toLowerCase();

                        String itemStatus;
                        if (item['is_treated'] == 1 ||
                            item['status'] == 'treated') {
                          itemStatus = 'treated';
                        } else if (item['severity_key'] == 'default' ||
                            item['disease_key'] == 'healthy') {
                          itemStatus = 'healthy';
                        } else {
                          itemStatus = 'infected';
                        }

                        final title = item['disease_key']
                            .toString()
                            .replaceAll('_', ' ')
                            .toLowerCase();
                        final date =
                            item['created_at'].toString().toLowerCase();

                        bool matchesSearch = title.contains(searchText) ||
                            itemStatus.contains(searchText) ||
                            date.contains(searchText);

                        bool matchesDate = true;
                        if (_controller.selectedDate != null) {
                          try {
                            final itemDate =
                                DateTime.parse(item['created_at'].toString());
                            final selected = _controller.selectedDate!;
                            matchesDate = itemDate.year == selected.year &&
                                itemDate.month == selected.month &&
                                itemDate.day == selected.day;
                          } catch (_) {
                            matchesDate = false;
                          }
                        }
                        bool matchesFilter = true;
                        if (_controller.activeFilter == "Healthy") {
                          matchesFilter = item['severity_key'] == 'default' ||
                              item['disease_key'] == 'healthy';
                        } else if (_controller.activeFilter == "Infected") {
                          matchesFilter = item['severity_key'] != 'default' &&
                              item['disease_key'] != 'healthy';
                        } else if (_controller.activeFilter == "Treated") {
                          matchesFilter = item['is_treated'] == 1 ||
                              item['status'] == 'treated';
                        }

                        return matchesSearch && matchesFilter && matchesDate;
                      }).toList();

                      if (filteredData.isEmpty) {
                        return _buildEmptyState(textPrimary, textSecondary);
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];

                          String displayStatus;
                          if (item['is_treated'] == 1 ||
                              item['status'] == 'treated') {
                            displayStatus = 'Treated';
                          } else if (item['severity_key'] == 'default' ||
                              item['disease_key'] == 'healthy') {
                            displayStatus = 'Healthy';
                          } else {
                            displayStatus = 'Infected';
                          }

                          final Map<String, dynamic> formattedData = {
                            "id": item['local_id'],
                            "title": item['disease_key']
                                .toString()
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            "date": item['created_at'],
                            "confidence":
                                (item['confidence'] * 100).toStringAsFixed(1),
                            "status": displayStatus,
                            "image": item['image_path'],
                            "isLocalFile": true,
                            "what_to_do_now_en": item['what_to_do_now_en'],
                            "prevention_en": item['prevention_en'],
                            "when_to_escalate_en": item['when_to_escalate_en'],
                            "what_to_do_now_tl": item['what_to_do_now_tl'],
                            "prevention_tl": item['prevention_tl'],
                            "when_to_escalate_tl": item['when_to_escalate_tl'],
                          };

                          return HistoryCard(
                            data: formattedData,
                            controller: _scanResultController,
                            onTap: () async {
                              _scanResultController.setInputs(
                                diseaseName: formattedData['title'],
                                severity: item['severity_key']?.toString() ??
                                    'default',
                              );

                              final hasGuideData =
                                  item['what_to_do_now_en'] != null &&
                                      item['what_to_do_now_en']
                                          .toString()
                                          .trim()
                                          .isNotEmpty;

                              if (hasGuideData) {
                                _scanResultController.loadFromHistory(item);
                              } else {
                                await _scanResultController.initGuide();
                              }

                              if (!context.mounted) return;
                              ScanDetailsSheet.show(
                                context,
                                formattedData,
                                _scanResultController,
                              );
                            },
                            onDeleteComplete: () => setState(() {}),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 96,
            right: 16,
          ),
          child: FloatingActionButton.extended(
            onPressed: _isSyncing
                ? null
                : () async {
                    setState(() {
                      _isSyncing = true;
                    });

                    final success = await _syncTrigger.forceSync();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Sync completed successfully!"
                              : "No pending data to sync.",
                        ),
                        backgroundColor: success
                            ? const Color(0xFF1B3022)
                            : const Color(0xFF8A6D3B),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    setState(() {
                      _isSyncing = false;
                    });

                    if (success) {
                      setState(() {});
                    }
                  },
            backgroundColor:
                _isSyncing ? const Color(0xFF6B7C72) : const Color(0xFF1B3022),
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white),
            label: Text(
              _isSyncing ? "Syncing..." : "Sync Data",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textPrimary, Color? textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FloatingGhost(),
            const SizedBox(height: 16),
            Text(
              "No cacao pods found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.activeFilter == "All Scans"
                  ? "Try scanning some cacao pods first!"
                  : "No items match the '${_controller.activeFilter}' filter.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    Color fillColor,
    Color textColor,
    Color? hintColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search scans...",
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(Icons.mic, color: iconColor),
          suffixIcon: Icon(Icons.search, color: iconColor),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
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