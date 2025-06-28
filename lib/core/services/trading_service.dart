import '../../session_manager.dart';
import 'finnhub_service.dart';

/// Trading Service - handles buy/sell operations
///
/// Following Lectures.md requirements: "Buy/Sell Orders: Execute market and limit orders"
/// Integrates with SessionManager for simplified in-memory state management
class TradingService {
  static final SessionManager _sessionManager = SessionManager();

  /// Execute a buy order
  ///
  /// [symbol] - Stock symbol to purchase
  /// [quantity] - Number of shares to buy
  /// [orderType] - Market or limit order (defaults to market)
  /// Returns true if successful, false otherwise
  static Future<bool> executeBuyOrder({
    required String symbol,
    required double quantity,
    String orderType = 'market',
  }) async {
    try {
      // Check if user has active session
      if (!_sessionManager.hasActiveSession) {
        print('TradingService: No active session');
        return false;
      }

      // Get current market price
      final stockData = await FinnhubService.getStockQuote(symbol);
      if (stockData == null) {
        print('TradingService: Could not get stock price for $symbol');
        return false;
      }

      final currentPrice = stockData['c']?.toDouble() ?? 0.0;
      if (currentPrice <= 0) {
        print('TradingService: Invalid price for $symbol');
        return false;
      }

      // Execute buy through SessionManager
      final success = await _sessionManager.buyStock(
        symbol,
        quantity,
        currentPrice,
      );

      if (success) {
        print(
          'TradingService: Successfully bought $quantity shares of $symbol at \$${currentPrice.toStringAsFixed(2)}',
        );
      } else {
        print('TradingService: Failed to execute buy order');
      }

      return success;
    } catch (e) {
      print('TradingService: Error executing buy order: $e');
      return false;
    }
  }

  /// Execute a sell order
  ///
  /// [symbol] - Stock symbol to sell
  /// [quantity] - Number of shares to sell
  /// [orderType] - Market or limit order (defaults to market)
  /// Returns true if successful, false otherwise
  static Future<bool> executeSellOrder({
    required String symbol,
    required double quantity,
    String orderType = 'market',
  }) async {
    try {
      // Check if user has active session
      if (!_sessionManager.hasActiveSession) {
        print('TradingService: No active session');
        return false;
      }

      // Execute sell through SessionManager
      final success = _sessionManager.sellStock(symbol, quantity);

      if (success) {
        print('TradingService: Successfully sold $quantity shares of $symbol');
      } else {
        print('TradingService: Failed to execute sell order');
      }

      return success;
    } catch (e) {
      print('TradingService: Error executing sell order: $e');
      return false;
    }
  }

  /// Get current portfolio
  ///
  /// Returns list of portfolio stocks from session
  static List<PortfolioStock> getPortfolio() {
    return _sessionManager.getPortfolio();
  }

  /// Get current watchlist
  ///
  /// Returns list of watchlist symbols from session
  static List<String> getWatchlist() {
    return _sessionManager.getWishlist();
  }

  /// Add stock to watchlist
  ///
  /// [symbol] - Stock symbol to add
  /// Returns true if successful, false otherwise
  static bool addToWatchlist(String symbol) {
    return _sessionManager.addToWishlist(symbol);
  }

  /// Remove stock from watchlist
  ///
  /// [symbol] - Stock symbol to remove
  /// Returns true if successful, false otherwise
  static bool removeFromWatchlist(String symbol) {
    return _sessionManager.removeFromWishlist(symbol);
  }

  /// Check if stock is in watchlist
  ///
  /// [symbol] - Stock symbol to check
  /// Returns true if in watchlist, false otherwise
  static bool isInWatchlist(String symbol) {
    return _sessionManager.isInWishlist(symbol);
  }
}
