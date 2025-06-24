import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = themeProvider.isLightMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with Dashboard title and action icons
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

            const Spacer(),

            // Search container
            Container(
              width: 111,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.getBG(brightness),
                border: Border.all(
                  color: AppColors.getText(brightness),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Icon(
                      Icons.search,
                      color: AppColors.getText(brightness),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Notification icon
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.getText(brightness),
                size: 24,
              ),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),

        const SizedBox(height: 8),

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
