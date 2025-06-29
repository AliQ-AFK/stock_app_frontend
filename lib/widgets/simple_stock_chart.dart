import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';

/// A helper class to hold the calculated values for an axis.
class _ChartAxisValues {
  final double min;
  final double max;
  final double interval;

  _ChartAxisValues({required this.min, required this.max, required this.interval});
}

/// Simple Stock Chart Widget
///
/// This definitive version uses a robust, mathematically-sound algorithm
/// to calculate "nice" intervals and boundaries for the Y-axis, guaranteeing
/// that labels are always spaced out and human-readable, solving the overlap
/// issue for all possible price ranges.
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
    if (dataPoints.length < 2) {
      return Center(child: Text("Not enough data for chart"));
    }

    final yAxisValues = _calculateYAxisValues();

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 4),
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: yAxisValues.interval,
                getTitlesWidget: leftTitleWidgets,
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getBottomTitleInterval(),
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: _createSpots(),
              isCurved: true,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.2),
              ),
            ),
          ],

          minY: yAxisValues.min,
          maxY: yAxisValues.max,
          minX: -0.2,
          maxX: (dataPoints.length - 1).toDouble() + 0.2,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: AppColors.getText(brightness).withOpacity(0.7),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    String text = value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return Text('\$$text', style: style, textAlign: TextAlign.center);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value.floor() != value) {
      return const SizedBox.shrink();
    }
    final style = TextStyle(
      color: AppColors.getText(brightness).withOpacity(0.7),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    if (timestamps == null || timestamps!.isEmpty) return Text('', style: style);
    final index = value.toInt();
    if (index >= 0 && index < timestamps!.length) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamps![index] * 1000);
      return Text(DateFormat('MMM d').format(date), style: style);
    }
    return Text('', style: style);
  }

  double _getBottomTitleInterval() {
    if (dataPoints.length <= 10) return 1;
    return (dataPoints.length / 4).floorToDouble();
  }

  _ChartAxisValues _calculateYAxisValues() {
    final minPrice = dataPoints.reduce(min);
    final maxPrice = dataPoints.reduce(max);

    if (minPrice == maxPrice) {
      return _ChartAxisValues(
        min: minPrice - 5.0,
        max: maxPrice + 5.0,
        interval: 2.5,
      );
    }

    final range = maxPrice - minPrice;
    int targetTickCount = 5;
    double tempInterval = range / (targetTickCount - 1);

    final magnitude = pow(10, (log(tempInterval) / log(10)).floor()).toDouble();
    final residual = tempInterval / magnitude;

    double niceInterval;
    // ================ THE SYNTAX FIX IS HERE ================
    // Changed all the integer literals (1, 2, 5, 10) to doubles (1.0, 2.0, etc.)
    if (residual < 1.5) {
      niceInterval = 1.0 * magnitude;
    } else if (residual < 3) {
      niceInterval = 2.0 * magnitude;
    } else if (residual < 7) {
      niceInterval = 5.0 * magnitude;
    } else {
      niceInterval = 10.0 * magnitude;
    }
    // ========================================================

    double niceMin = (minPrice / niceInterval).floor() * niceInterval;
    double niceMax = (maxPrice / niceInterval).ceil() * niceInterval;

    return _ChartAxisValues(min: niceMin, max: niceMax, interval: niceInterval);
  }

  List<FlSpot> _createSpots() {
    return dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }
}