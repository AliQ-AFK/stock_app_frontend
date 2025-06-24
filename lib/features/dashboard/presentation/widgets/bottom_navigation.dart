import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';

/// Bottom navigation widget
///
/// Displays the bottom navigation bar as shown in the Figma design
/// with home, portfolio, news, and profile icons.
class BottomNavigation extends StatelessWidget {
  /// Currently selected tab index
  final int currentIndex;

  /// Callback when a tab is selected
  final ValueChanged<int> onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBG(brightness),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                index: 0,
                brightness: brightness,
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet,
                index: 1,
                brightness: brightness,
              ),
              _buildNavItem(
                icon: Icons.article_outlined,
                selectedIcon: Icons.article,
                index: 2,
                brightness: brightness,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                index: 3,
                brightness: brightness,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required Brightness brightness,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? AppColors.getText(brightness)
              : AppColors.getText(brightness).withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }
}
