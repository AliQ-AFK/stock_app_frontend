import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';

class AlphaPro extends StatefulWidget {
  @override
  _AlphaProstate createState() => _AlphaProstate();
}

class _AlphaProstate extends State<AlphaPro> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.getBG(brightness),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AlphaWave',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: AppColors.getText(brightness),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getText(brightness),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Pro',
                style: TextStyle(
                  color: AppColors.getBG(brightness),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'for better experience with AlphaWave',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildFeature('Ad-free Experience'),
                  _buildFeature('Advanced Research & Exclusive Insights'),
                  _buildFeature('priority Customer Support'),
                  _buildFeature('Early Access to New Features'),
                  _buildFeature('Exclusive Webinars & Workshop'),
                  _buildFeature('Intelligent Alert & Notifications'),
                  _buildFeature('And more...'), const SizedBox(height: 20),

                  ///Month
                  _buildPlanCard(
                    context,
                    title: 'Monthly',
                    price: '\$50/ Month',
                    description: 'Month-to-month plan\nIncludes 7-day trial',
                  ),
                  SizedBox(height: 10),

                  ///Year
                  _buildPlanCard(
                    context,
                    title: 'Yearly',
                    price: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$600',
                            style: TextStyle(
                              color: AppColors.getText(
                                brightness,
                              ).withOpacity(0.5),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          TextSpan(
                            text: '  \$480/ Year',
                            style: TextStyle(
                              color: AppColors.getText(brightness),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    description:
                        'Save 20% when you pay yearly\nIncludes 30-day free trial',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.getText(brightness),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.getText(brightness),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPlanCard(
  BuildContext context, {
  required String title,
  required dynamic price,
  required String description,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final brightness = themeProvider.brightness;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.getGreyBG(brightness).withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.getText(brightness),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        price is String
            ? Text(
                price,
                style: TextStyle(
                  color: AppColors.getText(brightness),
                  fontSize: 16,
                ),
              )
            : price,
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: AppColors.getText(brightness)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getGreyBG(brightness),
              foregroundColor: AppColors.getText(brightness),
            ),
            child: const Text('Upgrade'),
          ),
        ),
      ],
    ),
  );
}
