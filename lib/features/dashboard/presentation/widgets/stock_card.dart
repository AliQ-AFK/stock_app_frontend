import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/models/stock.dart';

/// Stock card widget
///
/// Displays stock information in a compact card format as shown
/// in the Figma design with symbol, percentage change, and styling.
class StockCard extends StatelessWidget {
  /// The stock to display
  final Stock stock;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const StockCard({Key? key, required this.stock, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final changePercent = stock.calculateChangePercent();
    final isPositive = changePercent >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock logo/icon placeholder
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getStockColor(stock.symbol),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _getStockIcon(stock.symbol)),
            ),

            // Stock symbol and percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the brand color for different stocks
  Color _getStockColor(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Colors.red;
      case 'AAPL':
        return Colors.grey[800]!;
      case 'NVDA':
        return Colors.green[700]!;
      case 'AMD':
        return Colors.red[700]!;
      case 'META':
        return Colors.blue[700]!;
      case 'GOOGL':
        return Colors.blue[600]!;
      case 'MSFT':
        return Colors.blue[800]!;
      case 'AMZN':
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Gets the appropriate icon for different stocks
  Widget _getStockIcon(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return const Text(
          'T',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      case 'AAPL':
        return const Icon(Icons.apple, color: Colors.white, size: 16);
      case 'NVDA':
        return const Text(
          'N',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      case 'AMD':
        return const Text(
          'AMD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      case 'META':
        return const Text(
          'M',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      default:
        return Text(
          symbol.substring(0, 1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
    }
  }
}
