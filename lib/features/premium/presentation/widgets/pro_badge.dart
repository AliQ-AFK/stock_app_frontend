import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';

class ProBadge extends StatelessWidget {
  final Widget child;
  final bool showBadge;
  final double badgeSize;

  const ProBadge({
    Key? key,
    required this.child,
    required this.showBadge,
    this.badgeSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isDark = brightness == Brightness.dark;

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: AppColors.getGreen(brightness),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.getBG(brightness), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getText(brightness).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.star,
              color: AppColors.getBG(brightness),
              size: badgeSize * 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class ProBanner extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const ProBanner({
    Key? key,
    this.text = 'PRO',
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.getGreen(brightness),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.getText(brightness).withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppColors.getBG(brightness),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isPro;

  const ProProfilePicture({
    Key? key,
    this.imageUrl,
    this.size = 80,
    required this.isPro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isDark = brightness == Brightness.dark;

    return ProBadge(
      showBadge: isPro,
      badgeSize: size * 0.3,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isPro
              ? Border.all(color: AppColors.getGreen(brightness), width: 3)
              : Border.all(color: AppColors.getGreyBG(brightness), width: 2),
        ),
        child: ClipOval(
          child: imageUrl != null
              ? Image.asset(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(isDark);
                  },
                )
              : _buildDefaultAvatar(isDark),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Container(
      color: AppColors.getGreyBG(brightness),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: AppColors.getText(brightness).withOpacity(0.6),
      ),
    );
  }
}
