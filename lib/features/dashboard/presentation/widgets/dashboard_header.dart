import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/payment_service.dart';
import 'package:stock_app_frontend/features/premium/presentation/widgets/pro_badge.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

/// Dashboard header widget
///
/// Displays the dashboard title, user greeting, Pro badge,
/// search and notification icons as shown in the Figma design.
class DashboardHeader extends StatefulWidget {
  /// The current user
  final User user;

  const DashboardHeader({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardHeaderState createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  bool _isPro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  void _checkProStatus() async {
    bool proStatus = await PaymentService.getProStatus(widget.user.userID);
    setState(() {
      _isPro = proStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // User greeting section
        Row(
          children: [
            // Profile image with Pro badge
            ProProfilePicture(
              imageUrl: 'assets/images/profilepic.jpg',
              size: 48,
              isPro: _isPro,
            ),

            const SizedBox(width: 12),

            // Greeting text with Pro badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hi, ${widget.user.name}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getText(brightness),
                        ),
                      ),
                      if (_isPro) ...[
                        SizedBox(width: 8),
                        ProBanner(text: 'PRO'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isPro
                        ? 'Welcome back to AlphaWave Pro!'
                        : 'Welcome back to AlphaWave!',
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
