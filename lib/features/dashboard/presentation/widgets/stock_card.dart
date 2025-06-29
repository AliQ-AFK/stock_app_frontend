import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/models/stock.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';

/// Stock card widget
///
/// Displays stock information in a big card format matching trending stocks design
/// with symbol, price, percentage change, and navigation to stock details.
class StockCard extends StatelessWidget {
  /// The stock to display
  final Stock stock;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const StockCard({Key? key, required this.stock, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final changePercent = stock.calculateChangePercent();
    final isPositive = changePercent >= 0;

    return GestureDetector(
      onTap:
          onTap ??
          () {
            // Navigate to stock detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(symbol: stock.symbol),
              ),
            );
          },
      child: Container(
        width: 140, // Same width as trending stocks
        height: 150, // Same height as trending stocks
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getGreyBG(brightness),
          border: Border.all(
            color: AppColors.getText(brightness).withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Company logo - big and centered with real logo fetching
            Center(
              child: Container(
                width: 40, // Same size as trending stocks
                height: 40,
                decoration: BoxDecoration(
                  color: _getStockColor(stock.symbol),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureBuilder<String?>(
                    future: _fetchCompanyLogo(stock.symbol),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        // Show real company logo
                        return Image.network(
                          snapshot.data!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: _getStockIcon(stock.symbol));
                          },
                        );
                      } else {
                        // Show fallback icon
                        return Center(child: _getStockIcon(stock.symbol));
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Symbol - centered
            Center(
              child: Text(
                stock.symbol,
                style: TextStyle(
                  fontSize: 16, // Same as trending stocks
                  fontWeight: FontWeight.w600,
                  color: AppColors.getText(brightness),
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Price - centered
            Center(
              child: Text(
                '\$${stock.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14, // Same as trending stocks
                  color: AppColors.getText(brightness).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Change percentage - centered
            Center(
              child: Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 14, // Same as trending stocks
                  fontWeight: FontWeight.w500,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
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
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.pink,
        ];
        return colors[symbol.hashCode % colors.length];
    }
  }

  /// Gets the appropriate icon for different stocks
  Widget _getStockIcon(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Text(
          'T',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'AAPL':
        return Icon(Icons.apple, color: Colors.white, size: 24);
      case 'NVDA':
        return Text(
          'N',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'AMD':
        return Text(
          'AMD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'META':
        return Text(
          'f',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'GOOGL':
        return Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'MSFT':
        return Icon(Icons.window, color: Colors.white, size: 20);
      case 'AMZN':
        return Text(
          'a',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );
      default:
        return Text(
          symbol.substring(0, 1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
    }
  }

  /// Fetch company logo from API with error handling
  Future<String?> _fetchCompanyLogo(String symbol) async {
    if (symbol.isEmpty) return null;

    try {
      // Fetch company profile to get logo
      final companyProfile = await FinnhubService.getCompanyProfile(symbol);
      final logoUrl = companyProfile?['logo'] ?? '';

      return logoUrl.isNotEmpty ? logoUrl : null;
    } catch (e) {
      // Return null on error - will use fallback icon
      return null;
    }
  }
}
