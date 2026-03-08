import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final _reportService = ReportService();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String? _highlightReportId;
  bool _hasShownHighlight = false;

  @override
  void initState() {
    super.initState();
    _highlightReportId = Get.arguments as String?;
  }

  List<ReportModel> _applyFilters(List<ReportModel> reports) {
    var filtered = reports;

    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((r) => r.reportType == _selectedFilter.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) => r.playerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 2,
      title: 'All Reports',
      actions: [
        // Search
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search reports...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: AppColors.card,
            ),
          ),
        ),
        const SizedBox(width: 16),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'pitcher') {
              Get.toNamed('/report/pitcher');
            } else {
              Get.toNamed('/report/hitter');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'pitcher', child: Text('New Pitcher Report')),
            const PopupMenuItem(
                value: 'hitter', child: Text('New Hitter Report')),
          ],
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Report'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: StreamBuilder<List<ReportModel>>(
          stream: _reportService.streamReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading reports: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final allReports = snapshot.data ?? [];
            final filteredReports = _applyFilters(allReports);

            // Auto-scroll to highlighted report from report request
            if (_highlightReportId != null && !_hasShownHighlight && allReports.isNotEmpty) {
              _hasShownHighlight = true;
              final target = allReports.where((r) => r.id == _highlightReportId).firstOrNull;
              if (target != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchController.text = target.playerName;
                  setState(() => _searchQuery = target.playerName);
                });
              }
            }

            return Column(
              children: [
                // Filters
                Row(
                  children: [
                    _buildFilterChip('All', allReports.length),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Pitcher',
                      allReports
                          .where((r) => r.reportType == 'pitcher')
                          .length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Hitter',
                      allReports
                          .where((r) => r.reportType == 'hitter')
                          .length,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reports Grid
                Expanded(
                  child: filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 64,
                                  color:
                                      AppColors.gray.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                'No reports found',
                                style: TextStyle(
                                    color: AppColors.gray, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return _buildReportCard(report);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.white.withOpacity(0.2)
                  : AppColors.gray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.white : AppColors.gray,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.gray,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: AppColors.card,
      side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.inputBorder),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final isPitcher = report.reportType == 'pitcher';
    final typeColor =
        isPitcher ? AppColors.pitcherBlue : AppColors.hitterGreen;
    final isHighlighted = report.id == _highlightReportId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : typeColor.withOpacity(0.3),
          width: isHighlighted ? 3 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft:
                    Radius.circular(AppConstants.radiusMedium - 2),
                topRight:
                    Radius.circular(AppConstants.radiusMedium - 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      report.position,
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.playerName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isPitcher
                            ? 'Pitcher Report'
                            : 'Hitter Report',
                        style:
                            TextStyle(color: typeColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.gray, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(report);
                    }
                  },
                ),
              ],
            ),
          ),

          // Stats
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isPitcher
                        ? [
                            _buildStatItem(
                              'Peak Velo',
                              '${report.peakVelocity?.toStringAsFixed(1) ?? '-'} mph',
                            ),
                            _buildStatItem(
                              'Avg Spin',
                              '${report.avgSpinRate ?? '-'} rpm',
                            ),
                          ]
                        : [
                            _buildStatItem(
                              'Exit Velo',
                              '${report.hitterStats?.exitVelocity.toStringAsFixed(1) ?? '-'} mph',
                            ),
                            _buildStatItem(
                              'Batting Avg',
                              report.hitterStats?.battingAverage
                                      .toStringAsFixed(3) ??
                                  '-',
                            ),
                          ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color:
                          AppColors.inputBorder.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(report.createdAt),
                  style: const TextStyle(
                      color: AppColors.gray, fontSize: 12),
                ),
                Row(
                  children: [
                    if (report.videoUrl != null &&
                        report.videoUrl!.isNotEmpty)
                      const Icon(Icons.videocam_outlined,
                          size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    const Icon(Icons.insert_chart_outlined,
                        size: 16, color: AppColors.gray),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style:
              const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  void _showDeleteDialog(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Report',
            style: TextStyle(color: AppColors.white)),
        content: Text(
          'Are you sure you want to delete the report for ${report.playerName}?',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reportService.deleteReport(report.id);
                Get.snackbar(
                  'Deleted',
                  'Report deleted successfully',
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete report',
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
