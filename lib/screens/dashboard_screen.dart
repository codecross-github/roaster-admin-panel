import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../models/report_model.dart';
import '../models/report_request_model.dart';
import '../services/report_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reportService = ReportService();

  int _totalReports = 0;
  int _pendingRequests = 0;
  int _totalRequests = 0;
  bool _countsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final results = await Future.wait([
        _reportService.getTotalReportsCount(),
        _reportService.getPendingRequestsCount(),
        _reportService.getTotalRequestsCount(),
      ]);
      if (mounted) {
        setState(() {
          _totalReports = results[0];
          _pendingRequests = results[1];
          _totalRequests = results[2];
          _countsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard counts: $e');
      if (mounted) {
        setState(() => _countsLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 0,
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Requests',
                    value: _countsLoaded ? _totalRequests.toString() : '...',
                    icon: Icons.pending_actions_outlined,
                    iconColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending Requests',
                    value: _countsLoaded ? _pendingRequests.toString() : '...',
                    icon: Icons.hourglass_empty_outlined,
                    iconColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Reports',
                    value: _countsLoaded ? _totalReports.toString() : '...',
                    icon: Icons.article_outlined,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Second Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Report Requests
                Expanded(
                  flex: 2,
                  child: _buildRecentRequests(),
                ),
                const SizedBox(width: 16),
                // Quick Actions
                Expanded(
                  child: _buildQuickActions(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Third Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Reports
                Expanded(
                  child: _buildRecentReports(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.gray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Report Requests',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/report-requests'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder),
          StreamBuilder<List<ReportRequestModel>>(
            stream: _reportService.streamReportRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                );
              }

              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No requests yet',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ),
                );
              }

              final recent = requests.take(5).toList();
              return Column(
                children: recent.map((req) => _buildRequestItem(req)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(ReportRequestModel request) {
    final statusColor = request.status == 'Pending'
        ? AppColors.warning
        : request.status == 'In Progress'
            ? AppColors.info
            : AppColors.success;

    final typeColor = request.reportType == 'pitcher'
        ? AppColors.pitcherBlue
        : AppColors.hitterGreen;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
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
                  'Requested by ${request.userName}',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
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
            ),
          ),
          const SizedBox(width: 12),
          Container(
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
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDate(request.requestedAt),
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.sports_baseball_outlined,
            label: 'New Pitcher Report',
            color: AppColors.pitcherBlue,
            onTap: () => Get.toNamed('/report/pitcher'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.sports_cricket_outlined,
            label: 'New Hitter Report',
            color: AppColors.hitterGreen,
            onTap: () => Get.toNamed('/report/hitter'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.pending_actions_outlined,
            label: 'View Requests',
            color: AppColors.warning,
            onTap: () => Get.toNamed('/report-requests'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/reports'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ReportModel>>(
            stream: _reportService.streamReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                );
              }

              final reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No reports yet',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ),
                );
              }

              final recent = reports.take(5).toList();
              return Column(
                children:
                    recent.map((report) => _buildReportListItem(report)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportListItem(ReportModel report) {
    final typeColor = report.reportType == 'pitcher'
        ? AppColors.pitcherBlue
        : AppColors.hitterGreen;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              report.reportType == 'pitcher'
                  ? Icons.sports_baseball_outlined
                  : Icons.sports_cricket_outlined,
              color: typeColor,
              size: 18,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${report.reportType == 'pitcher' ? 'Pitcher' : 'Hitter'} Report',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatCreatedAt(report.createdAt),
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatCreatedAt(String isoDate) {
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
}
