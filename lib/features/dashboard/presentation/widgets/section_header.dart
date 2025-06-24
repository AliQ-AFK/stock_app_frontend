import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';

/// Section header widget
///
/// Displays section titles with optional action buttons like
/// "View all" or "See More" as shown in the Figma design.
class SectionHeader extends StatelessWidget {
  /// Title of the section
  final String title;

  /// Callback for "View all" button
  final VoidCallback? onViewAllPressed;

  /// Callback for "See More" button
  final VoidCallback? onSeeMorePressed;

  /// Whether to show the view all button
  final bool showViewAll;

  const SectionHeader({
    Key? key,
    required this.title,
    this.onViewAllPressed,
    this.onSeeMorePressed,
    this.showViewAll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Section title
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),

        // Action button (View all or See More)
        if (showViewAll &&
            (onViewAllPressed != null || onSeeMorePressed != null))
          TextButton(
            onPressed: onViewAllPressed ?? onSeeMorePressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  onViewAllPressed != null ? 'View all' : 'See More',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getText(brightness).withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.getText(brightness).withOpacity(0.7),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
