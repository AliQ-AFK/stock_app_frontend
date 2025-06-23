import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';

/// Dashboard header widget
///
/// Displays the dashboard title, user greeting, Pro badge,
/// search and notification icons as shown in the Figma design.
class DashboardHeader extends StatelessWidget {
  /// The current user
  final User user;

  const DashboardHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isLightMode = brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with Dashboard title, Pro badge, and action icons
        Row(
          children: [
            // Dashboard title
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),

            const SizedBox(width: 12),

            // Pro badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLightMode ? Colors.grey[300] : Colors.grey[700],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Pro',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getText(brightness),
                ),
              ),
            ),

            const Spacer(),

            // Search icon
            IconButton(
              onPressed: () {
                // TODO: Implement search functionality
              },
              icon: Icon(
                Icons.search,
                color: AppColors.getText(brightness),
                size: 24,
              ),
            ),

            // Notification icon
            IconButton(
              onPressed: () {
                // TODO: Implement notifications
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.getText(brightness),
                size: 24,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // User greeting section
        Row(
          children: [
            // Profile image
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
              backgroundImage: const AssetImage(
                'assets/images/profile_placeholder.png',
              ),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading error
              },
              child: Icon(Icons.person, color: Colors.grey[600], size: 24),
            ),

            const SizedBox(width: 12),

            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${user.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome back to AlphaWave!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.getText(brightness).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
