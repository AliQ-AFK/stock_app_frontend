import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/portfolio.dart';

/// Portfolio value card widget
///
/// Displays the portfolio total value with gain/loss information
/// in a prominent card as shown in the Figma design.
class PortfolioValueCard extends StatelessWidget {
  /// The user's portfolio
  final Portfolio portfolio;

  const PortfolioValueCard({Key? key, required this.portfolio})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isLightMode = brightness == Brightness.light;

    final totalValue = portfolio.totalValue;
    final gainLoss = portfolio.totalGainLoss;
    final gainLossPercent = portfolio.totalGainLossPercent;
    final isPositive = gainLoss >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.grey[400] : Colors.grey[600],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Portfolio Value label
          Text(
            'Portfolio Value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isLightMode ? Colors.black87 : Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          // Portfolio total value
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Gain/Loss information
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Up/Down arrow icon
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),

              const SizedBox(width: 4),

              // Gain/Loss amount and percentage
              Text(
                '${isPositive ? '+' : ''}\$${gainLoss.abs().toStringAsFixed(2)} (${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
