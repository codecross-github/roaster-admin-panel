import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;

  const AdminSidebar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.sidebarWidth,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sports_baseball,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ROSTER',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'RADAR',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.inputBorder, height: 1),

          const SizedBox(height: 16),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavSection('MAIN'),
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  route: '/dashboard',
                ),
                _buildNavItem(
                  icon: Icons.pending_actions_outlined,
                  label: 'Report Requests',
                  index: 1,
                  route: '/report-requests',
                  badge: 5,
                ),

                const SizedBox(height: 16),
                _buildNavSection('REPORTS'),
                _buildNavItem(
                  icon: Icons.article_outlined,
                  label: 'All Reports',
                  index: 2,
                  route: '/reports',
                ),
                _buildNavItem(
                  icon: Icons.sports_baseball_outlined,
                  label: 'New Pitcher Report',
                  index: 3,
                  route: '/report/pitcher',
                ),
                _buildNavItem(
                  icon: Icons.sports_cricket_outlined,
                  label: 'New Hitter Report',
                  index: 4,
                  route: '/report/hitter',
                ),

                const SizedBox(height: 16),
                _buildNavSection('MANAGEMENT'),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Players',
                  index: 5,
                  route: '/players',
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Users',
                  index: 6,
                  route: '/users',
                ),
              ],
            ),
          ),

          // Bottom Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.inputBorder),
              ),
            ),
            child: Column(
              children: [
                // Admin Profile
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: const Text(
                        'SA',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Super Admin',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'admin@rosterradar.com',
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.offAllNamed('/login'),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gray,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
    int? badge,
  }) {
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              Get.offAllNamed(route);
            }
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              border: isSelected
                  ? Border.all(color: AppColors.primary.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.gray,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
