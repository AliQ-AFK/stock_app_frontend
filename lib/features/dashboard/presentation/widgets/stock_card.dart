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
        width: 85,
        height: 100,
        padding: const EdgeInsets.all(10),
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getStockColor(stock.symbol),
                borderRadius: BorderRadius.circular(6),
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
        return Color(0xFFE31937); // Tesla red
      case 'AAPL':
        return Color(0xFF000000); // Apple black
      case 'NVDA':
        return Color(0xFF76B900); // NVIDIA green
      case 'AMD':
        return Color(0xFFED1C24); // AMD red
      case 'META':
        return Color(0xFF0866FF); // Meta blue
      case 'GOOGL':
        return Color(0xFF4285F4); // Google blue
      case 'MSFT':
        return Color(0xFF00BCF2); // Microsoft blue
      case 'AMZN':
        return Color(0xFFFF9900); // Amazon orange
      default:
        return Colors.grey[600]!;
    }
  }

  /// Gets the appropriate icon for different stocks
  Widget _getStockIcon(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            'T',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'System',
            ),
          ),
        );
      case 'AAPL':
        return Container(
          padding: EdgeInsets.all(2),
          child: Icon(Icons.apple, color: Colors.white, size: 20),
        );
      case 'NVDA':
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            'N',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 'AMD':
        return Container(
          padding: EdgeInsets.all(2),
          child: Text(
            'AMD',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      case 'META':
        return Container(
          padding: EdgeInsets.all(4),
          child: Transform.rotate(
            angle: 0.1,
            child: Text(
              'f',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'GOOGL':
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      case 'MSFT':
        return Container(
          padding: EdgeInsets.all(2),
          child: Icon(Icons.window, color: Colors.white, size: 18),
        );
      case 'AMZN':
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            'a',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            symbol.substring(0, 1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
    }
  }
}
