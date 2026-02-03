import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                    title: 'Total Users',
                    value: '1,234',
                    change: '+12%',
                    changePositive: true,
                    icon: Icons.people_outline,
                    iconColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Premium Users',
                    value: '456',
                    change: '+8%',
                    changePositive: true,
                    icon: Icons.star_outline,
                    iconColor: AppColors.premium,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Reports',
                    value: '789',
                    change: '+23%',
                    changePositive: true,
                    icon: Icons.article_outlined,
                    iconColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending Requests',
                    value: '12',
                    change: '5 new',
                    changePositive: false,
                    icon: Icons.pending_actions_outlined,
                    iconColor: AppColors.warning,
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
                const SizedBox(width: 16),
                // Recent Users
                Expanded(
                  child: _buildRecentUsers(),
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
    required String change,
    required bool changePositive,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (changePositive ? AppColors.success : AppColors.warning)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changePositive ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    final requests = [
      {'user': 'John Smith', 'player': 'Mike Johnson', 'type': 'Pitcher', 'status': 'Pending', 'date': '2 hours ago'},
      {'user': 'Jane Doe', 'player': 'Chris Williams', 'type': 'Hitter', 'status': 'In Progress', 'date': '5 hours ago'},
      {'user': 'Bob Wilson', 'player': 'Alex Brown', 'type': 'Pitcher', 'status': 'Pending', 'date': '1 day ago'},
      {'user': 'Sarah Miller', 'player': 'David Lee', 'type': 'Hitter', 'status': 'Pending', 'date': '2 days ago'},
    ];

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
          ...requests.map((req) => _buildRequestItem(req)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Map<String, String> request) {
    final statusColor = request['status'] == 'Pending'
        ? AppColors.warning
        : request['status'] == 'In Progress'
            ? AppColors.info
            : AppColors.success;

    final typeColor = request['type'] == 'Pitcher'
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
                  request['player']!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Requested by ${request['user']}',
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
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
              request['type']!,
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
              request['status']!,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            request['date']!,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 12,
            ),
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
            icon: Icons.person_add_outlined,
            label: 'Add New Player',
            color: AppColors.primary,
            onTap: () => Get.toNamed('/players'),
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
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
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
    final reports = [
      {'player': 'Mike Johnson', 'type': 'Pitcher', 'date': 'Jan 15, 2024'},
      {'player': 'Chris Williams', 'type': 'Hitter', 'date': 'Jan 14, 2024'},
      {'player': 'Alex Brown', 'type': 'Pitcher', 'date': 'Jan 13, 2024'},
      {'player': 'David Lee', 'type': 'Hitter', 'date': 'Jan 12, 2024'},
      {'player': 'Ryan Garcia', 'type': 'Pitcher', 'date': 'Jan 11, 2024'},
    ];

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
          ...reports.map((report) => _buildReportListItem(report)),
        ],
      ),
    );
  }

  Widget _buildReportListItem(Map<String, String> report) {
    final typeColor = report['type'] == 'Pitcher'
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
              report['type'] == 'Pitcher'
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
                  report['player']!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${report['type']} Report',
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            report['date']!,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers() {
    final users = [
      {'name': 'John Smith', 'email': 'john@example.com', 'premium': true},
      {'name': 'Jane Doe', 'email': 'jane@example.com', 'premium': false},
      {'name': 'Bob Wilson', 'email': 'bob@example.com', 'premium': true},
      {'name': 'Sarah Miller', 'email': 'sarah@example.com', 'premium': false},
      {'name': 'Tom Davis', 'email': 'tom@example.com', 'premium': true},
    ];

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
                'Recent Users',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/users'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...users.map((user) => _buildUserListItem(user)),
        ],
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              user['name']!.toString().substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user['email']!,
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (user['premium'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.premium.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: AppColors.premium, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: AppColors.premium,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
