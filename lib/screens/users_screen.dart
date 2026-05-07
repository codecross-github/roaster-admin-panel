import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_layout.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _userService = UserService();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  String _sortField = 'name'; // 'name' or 'date'
  bool _sortAscending = true;

  List<UserModel> _applyFilters(List<UserModel> users) {
    var filtered = users;

    if (_selectedFilter == 'Premium') {
      filtered = filtered.where((u) => u.isPremium).toList();
    } else if (_selectedFilter == 'Free') {
      filtered = filtered.where((u) => !u.isPremium).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      int cmp;
      if (_sortField == 'date') {
        cmp = a.createdAt.compareTo(b.createdAt);
      } else {
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  void _onSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = true;
      }
    });
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
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: StreamBuilder<List<UserModel>>(
          stream: _userService.streamUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading users: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final allUsers = snapshot.data ?? [];
            final filteredUsers = _applyFilters(allUsers);

            return Column(
              children: [
                // New-user premium setting
                StreamBuilder<bool>(
                  stream: _userService.streamIsNewUserPremium(),
                  builder: (context, settingSnap) {
                    final isNewUserPremium = settingSnap.data ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                            color: isNewUserPremium
                                ? AppColors.premium.withOpacity(0.4)
                                : AppColors.inputBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.new_releases_outlined,
                            color: isNewUserPremium
                                ? AppColors.premium
                                : AppColors.gray,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New User Registration',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  isNewUserPremium
                                      ? 'New users are created as Premium'
                                      : 'New users are created as Free',
                                  style: const TextStyle(
                                      color: AppColors.gray, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isNewUserPremium,
                            onChanged: (value) async {
                              try {
                                await _userService.setIsNewUserPremium(value);
                                Get.snackbar(
                                  'Updated',
                                  'New users will be created as ${value ? 'Premium' : 'Free'}',
                                  backgroundColor: value
                                      ? AppColors.premium
                                      : AppColors.gray,
                                  colorText: AppColors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to update setting',
                                  backgroundColor: AppColors.error,
                                  colorText: AppColors.white,
                                );
                              }
                            },
                            activeColor: AppColors.premium,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                        'Total Users', allUsers.length, AppColors.info),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Premium',
                      allUsers.where((u) => u.isPremium).length,
                      AppColors.premium,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Free',
                      allUsers.where((u) => !u.isPremium).length,
                      AppColors.gray,
                    ),
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
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64,
                                  color: AppColors.gray.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No users match "$_searchQuery"'
                                    : 'No users found',
                                style: const TextStyle(
                                    color: AppColors.gray, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusMedium),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                decoration: const BoxDecoration(
                                  color: AppColors.sidebarBg,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        AppConstants.radiusMedium),
                                    topRight: Radius.circular(
                                        AppConstants.radiusMedium),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildHeaderCell('User', flex: 2, sortKey: 'name'),
                                    _buildHeaderCell('Status'),
                                    _buildHeaderCell('Joined', sortKey: 'date'),
                                    _buildHeaderCell('Saved Players'),
                                    _buildHeaderCell('Reports'),
                                    _buildHeaderCell('Actions'),
                                  ],
                                ),
                              ),

                              // Body
                              Expanded(
                                child: ListView.separated(
                                  itemCount: filteredUsers.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      color: AppColors.inputBorder, height: 1),
                                  itemBuilder: (context, index) {
                                    return _buildUserRow(filteredUsers[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
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
      side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.inputBorder),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, String? sortKey}) {
    final isSorted = sortKey != null && _sortField == sortKey;
    return Expanded(
      flex: flex,
      child: sortKey != null
          ? InkWell(
              onTap: () => _onSort(sortKey),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isSorted ? AppColors.primary : AppColors.gray,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isSorted
                        ? (_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.unfold_more,
                    size: 14,
                    color: isSorted ? AppColors.primary : AppColors.gray,
                  ),
                ],
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
    );
  }

  Widget _buildUserRow(UserModel user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

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
                  backgroundImage:
                      user.photo != null ? NetworkImage(user.photo!) : null,
                  child: user.photo == null
                      ? Text(initial,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.gray, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            child: user.isPremium
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.premium.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppColors.premium, size: 14),
                        SizedBox(width: 4),
                        Text('Premium',
                            style: TextStyle(
                                color: AppColors.premium,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Free',
                        style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
          ),

          // Joined
          Expanded(
              child: Text(_formatDate(user.createdAt),
                  style: const TextStyle(color: AppColors.gray))),

          // Saved Players
          Expanded(
              child: Text('${user.savedPlayersCount}',
                  style: const TextStyle(color: AppColors.white))),

          // Reports
          Expanded(
              child: Text('${user.reportsRequestedCount}',
                  style: const TextStyle(color: AppColors.white))),

          // Actions
          Expanded(
            child: Row(
              children: [
                Switch(
                  value: user.isPremium,
                  onChanged: (value) async {
                    try {
                      await _userService.togglePremium(user.id, value);
                      Get.snackbar(
                        'Updated',
                        '${user.name} is now ${value ? 'Premium' : 'Free'}',
                        backgroundColor:
                            value ? AppColors.premium : AppColors.gray,
                        colorText: AppColors.white,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to update user status',
                        backgroundColor: AppColors.error,
                        colorText: AppColors.white,
                      );
                    }
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage:
                  user.photo != null ? NetworkImage(user.photo!) : null,
              child: user.photo == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style:
                        const TextStyle(color: AppColors.white, fontSize: 18)),
                Text(user.email,
                    style:
                        const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', user.isPremium ? 'Premium' : 'Free'),
              _buildDetailRow('Member Since', _formatDate(user.createdAt)),
              if (user.lastLoginAt != null)
                _buildDetailRow('Last Login', _formatDate(user.lastLoginAt!)),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildDetailRow('Phone', user.phone!),
              _buildDetailRow(
                  'Saved Players', '${user.savedPlayersCount}'),
              _buildDetailRow(
                  'Reports Requested', '${user.reportsRequestedCount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
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
          Text(value,
              style: const TextStyle(
                  color: AppColors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
