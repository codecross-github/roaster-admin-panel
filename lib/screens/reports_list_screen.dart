import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'playerName': 'Mike Johnson',
      'position': 'RHP',
      'type': 'pitcher',
      'createdAt': '2024-01-15',
      'peakVelo': 96.5,
      'avgSpin': 2450,
    },
    {
      'id': '2',
      'playerName': 'Chris Williams',
      'position': 'CF',
      'type': 'hitter',
      'createdAt': '2024-01-14',
      'exitVelo': 94.2,
      'battingAvg': .312,
    },
    {
      'id': '3',
      'playerName': 'Alex Brown',
      'position': 'LHP',
      'type': 'pitcher',
      'createdAt': '2024-01-13',
      'peakVelo': 93.2,
      'avgSpin': 2380,
    },
    {
      'id': '4',
      'playerName': 'David Lee',
      'position': 'SS',
      'type': 'hitter',
      'createdAt': '2024-01-12',
      'exitVelo': 91.8,
      'battingAvg': .285,
    },
    {
      'id': '5',
      'playerName': 'Ryan Garcia',
      'position': 'RHP',
      'type': 'pitcher',
      'createdAt': '2024-01-11',
      'peakVelo': 98.1,
      'avgSpin': 2520,
    },
    {
      'id': '6',
      'playerName': 'James Wilson',
      'position': '1B',
      'type': 'hitter',
      'createdAt': '2024-01-10',
      'exitVelo': 96.5,
      'battingAvg': .298,
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    var reports = _reports;

    if (_selectedFilter != 'All') {
      reports = reports.where((r) => r['type'] == _selectedFilter.toLowerCase()).toList();
    }

    if (_searchQuery.isNotEmpty) {
      reports = reports.where((r) =>
          r['playerName'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return reports;
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
              prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            const PopupMenuItem(value: 'pitcher', child: Text('New Pitcher Report')),
            const PopupMenuItem(value: 'hitter', child: Text('New Hitter Report')),
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
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                _buildFilterChip('All', _reports.length),
                const SizedBox(width: 8),
                _buildFilterChip('Pitcher', _reports.where((r) => r['type'] == 'pitcher').length),
                const SizedBox(width: 8),
                _buildFilterChip('Hitter', _reports.where((r) => r['type'] == 'hitter').length),
              ],
            ),

            const SizedBox(height: 24),

            // Reports Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: _filteredReports.length,
                itemBuilder: (context, index) {
                  final report = _filteredReports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.white.withOpacity(0.2) : AppColors.gray.withOpacity(0.3),
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
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.inputBorder),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final isPitcher = report['type'] == 'pitcher';
    final typeColor = isPitcher ? AppColors.pitcherBlue : AppColors.hitterGreen;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: typeColor.withOpacity(0.3), width: 2),
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
                topLeft: Radius.circular(AppConstants.radiusMedium - 2),
                topRight: Radius.circular(AppConstants.radiusMedium - 2),
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
                      report['position'],
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
                        report['playerName'],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isPitcher ? 'Pitcher Report' : 'Hitter Report',
                        style: TextStyle(color: typeColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.gray, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.toNamed(isPitcher ? '/report/pitcher' : '/report/hitter');
                    } else if (value == 'delete') {
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
                            _buildStatItem('Peak Velo', '${report['peakVelo']} mph'),
                            _buildStatItem('Avg Spin', '${report['avgSpin']} rpm'),
                          ]
                        : [
                            _buildStatItem('Exit Velo', '${report['exitVelo']} mph'),
                            _buildStatItem('Batting Avg', report['battingAvg'].toStringAsFixed(3)),
                          ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.inputBorder.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report['createdAt'],
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
                Row(
                  children: [
                    Icon(Icons.videocam_outlined, size: 16, color: AppColors.gray),
                    const SizedBox(width: 4),
                    Icon(Icons.insert_chart_outlined, size: 16, color: AppColors.gray),
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
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Report', style: TextStyle(color: AppColors.white)),
        content: Text(
          'Are you sure you want to delete the report for ${report['playerName']}?',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _reports.removeWhere((r) => r['id'] == report['id']);
              });
              Get.snackbar(
                'Deleted',
                'Report deleted successfully',
                backgroundColor: AppColors.error,
                colorText: AppColors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
