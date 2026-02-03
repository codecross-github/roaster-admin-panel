import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {'id': '1', 'name': 'John Smith', 'email': 'john@example.com', 'isPremium': true, 'createdAt': '2024-01-10', 'savedPlayers': 15, 'reports': 5},
    {'id': '2', 'name': 'Jane Doe', 'email': 'jane@example.com', 'isPremium': false, 'createdAt': '2024-01-08', 'savedPlayers': 8, 'reports': 0},
    {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com', 'isPremium': true, 'createdAt': '2024-01-05', 'savedPlayers': 22, 'reports': 3},
    {'id': '4', 'name': 'Sarah Miller', 'email': 'sarah@example.com', 'isPremium': false, 'createdAt': '2024-01-03', 'savedPlayers': 5, 'reports': 0},
    {'id': '5', 'name': 'Tom Davis', 'email': 'tom@example.com', 'isPremium': true, 'createdAt': '2024-01-01', 'savedPlayers': 30, 'reports': 8},
    {'id': '6', 'name': 'Emily Brown', 'email': 'emily@example.com', 'isPremium': false, 'createdAt': '2023-12-28', 'savedPlayers': 12, 'reports': 0},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    var users = _users;

    if (_selectedFilter == 'Premium') {
      users = users.where((u) => u['isPremium'] == true).toList();
    } else if (_selectedFilter == 'Free') {
      users = users.where((u) => u['isPremium'] == false).toList();
    }

    if (_searchQuery.isNotEmpty) {
      users = users.where((u) =>
          u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 6,
      title: 'Users Management',
      actions: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                _buildStatCard('Total Users', _users.length, AppColors.info),
                const SizedBox(width: 16),
                _buildStatCard('Premium', _users.where((u) => u['isPremium'] == true).length, AppColors.premium),
                const SizedBox(width: 16),
                _buildStatCard('Free', _users.where((u) => u['isPremium'] == false).length, AppColors.gray),
              ],
            ),

            const SizedBox(height: 24),

            // Filters
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Premium'),
                const SizedBox(width: 8),
                _buildFilterChip('Free'),
              ],
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
                    // Header
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
                          _buildHeaderCell('User', flex: 2),
                          _buildHeaderCell('Status'),
                          _buildHeaderCell('Joined'),
                          _buildHeaderCell('Saved Players'),
                          _buildHeaderCell('Reports'),
                          _buildHeaderCell('Actions'),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.inputBorder, height: 1),
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserRow(user);
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

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                label == 'Premium' ? Icons.star : Icons.people_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: const TextStyle(color: AppColors.gray)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
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

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.gray, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // User
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    user['name'].toString().substring(0, 1),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
                    Text(user['email'], style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            child: user['isPremium']
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.premium.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, color: AppColors.premium, size: 14),
                        SizedBox(width: 4),
                        Text('Premium', style: TextStyle(color: AppColors.premium, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Free', style: TextStyle(color: AppColors.gray, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
          ),

          // Joined
          Expanded(child: Text(user['createdAt'], style: const TextStyle(color: AppColors.gray))),

          // Saved Players
          Expanded(child: Text('${user['savedPlayers']}', style: const TextStyle(color: AppColors.white))),

          // Reports
          Expanded(child: Text('${user['reports']}', style: const TextStyle(color: AppColors.white))),

          // Actions
          Expanded(
            child: Row(
              children: [
                Switch(
                  value: user['isPremium'],
                  onChanged: (value) {
                    setState(() {
                      final index = _users.indexWhere((u) => u['id'] == user['id']);
                      _users[index]['isPremium'] = value;
                    });
                    Get.snackbar(
                      'Updated',
                      '${user['name']} is now ${value ? 'Premium' : 'Free'}',
                      backgroundColor: value ? AppColors.premium : AppColors.gray,
                      colorText: AppColors.white,
                    );
                  },
                  activeColor: AppColors.premium,
                ),
                IconButton(
                  onPressed: () => _showUserDetails(user),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  color: AppColors.gray,
                  tooltip: 'View Details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                user['name'].toString().substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: const TextStyle(color: AppColors.white, fontSize: 18)),
                Text(user['email'], style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', user['isPremium'] ? 'Premium' : 'Free'),
              _buildDetailRow('Member Since', user['createdAt']),
              _buildDetailRow('Saved Players', '${user['savedPlayers']}'),
              _buildDetailRow('Reports Requested', '${user['reports']}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray)),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
