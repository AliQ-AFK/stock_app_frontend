import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';

/// Simple Stock Chart Widget
///
/// Following Lectures.md principles: "keep it simple" - clean visual design
/// Dynamic color based on stock performance (green up, red down)
class SimpleStockChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<int>? timestamps;
  final Color lineColor;
  final Brightness brightness;

  const SimpleStockChart({
    Key? key,
    required this.dataPoints,
    this.timestamps,
    required this.lineColor,
    required this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Following Lectures.md: "keep it simple" - minimal but visible chart styling
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          // Hide grids and borders for clean look
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),

          // Show Y-axis with dollar values and X-axis with dates
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: timestamps != null && timestamps!.isNotEmpty,
                interval: _getDateInterval(),
                reservedSize: 30,
                getTitlesWidget: (value, meta) => _buildDateLabel(value),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000, // Large interval to prevent extra labels
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  final targetLabels = _getFiveEqualLabels();
                  final roundedValue = value.round();

                  // Only show if it matches one of our 5 target labels
                  if (targetLabels.contains(roundedValue)) {
                    return Text(
                      '\$${roundedValue}',
                      style: TextStyle(
                        color: AppColors.getText(brightness).withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Hide unwanted labels
                },
              ),
            ),
          ),

          // Create line chart data
          lineBarsData: [
            LineChartBarData(
              spots: _createSpots(),
              isCurved: true,
              color: lineColor,
              barWidth: 3, // Increased for better visibility
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),

              // Add area below the line with more opacity for better visibility
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.2),
              ),
            ),
          ],

          // Clean appearance with proper padding - prevent overlapping labels
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: minY, // Use getter for consistency
          maxY: maxY, // Use getter for consistency
        ),
      ),
    );
  }

  /// Convert price data to chart spots
  List<FlSpot> _createSpots() {
    return dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  /// Get minimum price for chart scaling
  double _getMinPrice() {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.reduce((a, b) => a < b ? a : b);
  }

  /// Get maximum price for chart scaling
  double _getMaxPrice() {
    if (dataPoints.isEmpty) return 100;
    return dataPoints.reduce((a, b) => a > b ? a : b);
  }

  /// Get chart minimum Y value
  double get minY => _getMinPrice() * 0.95;

  /// Get chart maximum Y value
  double get maxY => _getMaxPrice() * 1.05;

  /// Get exactly 5 equally spaced labels
  List<int> _getFiveEqualLabels() {
    final range = maxY - minY;
    final step = range / 4; // 4 steps = 5 labels

    return [
      minY.round(),
      (minY + step).round(),
      (minY + 2 * step).round(),
      (minY + 3 * step).round(),
      maxY.round(),
    ];
  }

  /// Calculate smart interval for date labels to prevent overlap
  /// Following Lectures.md: "keep it simple" - basic interval calculation
  double _getDateInterval() {
    if (dataPoints.length <= 5) return 1.0;
    if (dataPoints.length <= 15) return 3.0;
    return (dataPoints.length / 4).ceilToDouble(); // Show about 4-5 date labels
  }

  /// Build date label widget for X-axis
  /// Following Lectures.md: "keep it simple" - clean date formatting
  Widget _buildDateLabel(double value) {
    if (timestamps == null || timestamps!.isEmpty) {
      return const SizedBox.shrink();
    }

    final index = value.toInt();
    if (index < 0 || index >= timestamps!.length) {
      return const SizedBox.shrink();
    }

    final timestamp = timestamps![index];
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formattedDate = DateFormat('MMM d').format(date);

    return Text(
      formattedDate,
      style: TextStyle(
        color: AppColors.getText(brightness).withOpacity(0.7),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
