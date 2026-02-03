import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final int currentIndex;
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AdminLayout({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(currentIndex: currentIndex),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(color: AppColors.inputBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (actions != null) ...actions!,
                      const SizedBox(width: 16),
                      // Notifications
                      IconButton(
                        onPressed: () {},
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, color: AppColors.gray),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
