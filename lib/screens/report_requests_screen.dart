import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../models/report_request_model.dart';

class ReportRequestsScreen extends StatefulWidget {
  const ReportRequestsScreen({super.key});

  @override
  State<ReportRequestsScreen> createState() => _ReportRequestsScreenState();
}

class _ReportRequestsScreenState extends State<ReportRequestsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'In Progress', 'Completed'];

  // Sample data
  final List<ReportRequestModel> _requests = [
    ReportRequestModel(
      id: '1',
      userId: 'u1',
      userName: 'John Smith',
      userEmail: 'john@example.com',
      playerId: 'p1',
      playerName: 'Mike Johnson',
      playerPosition: 'RHP',
      reportType: 'pitcher',
      status: 'Pending',
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReportRequestModel(
      id: '2',
      userId: 'u2',
      userName: 'Jane Doe',
      userEmail: 'jane@example.com',
      playerId: 'p2',
      playerName: 'Chris Williams',
      playerPosition: 'LF',
      reportType: 'hitter',
      status: 'In Progress',
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ReportRequestModel(
      id: '3',
      userId: 'u3',
      userName: 'Bob Wilson',
      userEmail: 'bob@example.com',
      playerId: 'p3',
      playerName: 'Alex Brown',
      playerPosition: 'LHP',
      reportType: 'pitcher',
      status: 'Pending',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReportRequestModel(
      id: '4',
      userId: 'u4',
      userName: 'Sarah Miller',
      userEmail: 'sarah@example.com',
      playerId: 'p4',
      playerName: 'David Lee',
      playerPosition: 'CF',
      reportType: 'hitter',
      status: 'Completed',
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReportRequestModel(
      id: '5',
      userId: 'u5',
      userName: 'Tom Davis',
      userEmail: 'tom@example.com',
      playerId: 'p5',
      playerName: 'Ryan Garcia',
      playerPosition: 'RHP',
      reportType: 'pitcher',
      status: 'Pending',
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<ReportRequestModel> get _filteredRequests {
    if (_selectedFilter == 'All') return _requests;
    return _requests.where((r) => r.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 1,
      title: 'Report Requests',
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                _buildStatBadge(
                  'Total',
                  _requests.length,
                  AppColors.info,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  'Pending',
                  _requests.where((r) => r.status == 'Pending').length,
                  AppColors.warning,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  'In Progress',
                  _requests.where((r) => r.status == 'In Progress').length,
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  'Completed',
                  _requests.where((r) => r.status == 'Completed').length,
                  AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filters
            Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.gray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: AppColors.card,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.inputBorder,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.sidebarBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusMedium),
                          topRight: Radius.circular(AppConstants.radiusMedium),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('Player', flex: 2),
                          _buildHeaderCell('Requested By', flex: 2),
                          _buildHeaderCell('Type', flex: 1),
                          _buildHeaderCell('Status', flex: 1),
                          _buildHeaderCell('Requested', flex: 1),
                          _buildHeaderCell('Actions', flex: 1),
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredRequests.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: AppColors.inputBorder,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final request = _filteredRequests[index];
                          return _buildRequestRow(request);
                        },
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

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gray,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildRequestRow(ReportRequestModel request) {
    final statusColor = request.status == 'Pending'
        ? AppColors.warning
        : request.status == 'In Progress'
            ? AppColors.info
            : AppColors.success;

    final typeColor = request.reportType == 'pitcher'
        ? AppColors.pitcherBlue
        : AppColors.hitterGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Player
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      request.playerPosition,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.playerName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      request.playerPosition,
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Requested By
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  request.userEmail,
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Type
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.reportType == 'pitcher' ? 'Pitcher' : 'Hitter',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Requested Date
          Expanded(
            flex: 1,
            child: Text(
              _formatDate(request.requestedAt),
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 13,
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (request.status != 'Completed') ...[
                  IconButton(
                    onPressed: () {
                      // Navigate to create report
                      if (request.reportType == 'pitcher') {
                        Get.toNamed('/report/pitcher', arguments: request);
                      } else {
                        Get.toNamed('/report/hitter', arguments: request);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Create Report',
                    color: AppColors.primary,
                  ),
                  IconButton(
                    onPressed: () => _updateStatus(request),
                    icon: const Icon(Icons.update_outlined, size: 18),
                    tooltip: 'Update Status',
                    color: AppColors.info,
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    tooltip: 'View Report',
                    color: AppColors.gray,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _updateStatus(ReportRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Update Status',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update status for ${request.playerName}\'s report request',
              style: const TextStyle(color: AppColors.gray),
            ),
            const SizedBox(height: 16),
            ...AppConstants.reportStatuses.map((status) {
              return ListTile(
                title: Text(
                  status,
                  style: const TextStyle(color: AppColors.white),
                ),
                leading: Radio<String>(
                  value: status,
                  groupValue: request.status,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      // Update status logic would go here
                    });
                    Get.snackbar(
                      'Status Updated',
                      'Request status updated to $value',
                      backgroundColor: AppColors.success,
                      colorText: AppColors.white,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
