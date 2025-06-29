/// Session Manager for In-Memory State Management
///
/// This file contains all models and the singleton SessionManager class
/// for handling user portfolio and wishlist data temporarily in memory.
/// Following lectures.md "core features first" principle with simplicity.

import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/location_service.dart';

/// Portfolio Stock Model - simplified for session-only storage
class PortfolioStock {
  final String symbol;
  final String companyName;
  final String logoUrl;
  double quantity;
  double averagePurchasePrice;
  final DateTime purchaseDate;

  PortfolioStock({
    required this.symbol,
    required this.companyName,
    required this.logoUrl,
    required this.quantity,
    required this.averagePurchasePrice,
    DateTime? purchaseDate,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  /// Calculate total value at current market price
  double getTotalValue(double currentPrice) {
    return quantity * currentPrice;
  }

  /// Calculate profit/loss based on current market price
  double getProfitLoss(double currentPrice) {
    return (currentPrice - averagePurchasePrice) * quantity;
  }

  /// Calculate profit/loss percentage
  double getProfitLossPercentage(double currentPrice) {
    if (averagePurchasePrice == 0) return 0.0;
    return ((currentPrice - averagePurchasePrice) / averagePurchasePrice) * 100;
  }

  @override
  String toString() {
    return 'PortfolioStock{symbol: $symbol, quantity: $quantity, averagePurchasePrice: $averagePurchasePrice}';
  }
}

/// User Session Model - simplified for session-only storage
class UserSession {
  final String username;
  final DateTime sessionStart;
  String? detectedCountry;

  UserSession({
    required this.username,
    DateTime? sessionStart,
    this.detectedCountry,
  }) : sessionStart = sessionStart ?? DateTime.now();

  @override
  String toString() {
    return 'UserSession{username: $username, sessionStart: $sessionStart, detectedCountry: $detectedCountry}';
  }
}

/// SessionManager Singleton - manages all in-memory state
///
/// This class handles all temporary user data including portfolio and wishlist.
/// Data is intentionally lost when the app is closed for simplicity.
/// Following lectures.md performance criteria with synchronous operations.
class SessionManager {
  // Singleton pattern
  static SessionManager? _instance;
  SessionManager._internal();

  factory SessionManager() {
    _instance ??= SessionManager._internal();
    return _instance!;
  }

  // Session state variables
  UserSession? _currentUser;
  final List<PortfolioStock> _portfolio = [];
  final List<String> _wishlist = [];

  /// Start a new user session
  /// Clears all previous session data and creates new session
  void startSession(String username) {
    print('Starting new session for: $username');

    _currentUser = UserSession(username: username);
    _portfolio.clear();
    _wishlist.clear();

    print('Session started successfully');
  }

  /// End current session
  /// Clears all session data
  void endSession() {
    print('Ending current session');

    _currentUser = null;
    _portfolio.clear();
    _wishlist.clear();

    print('Session ended, all data cleared');
  }

  /// Get current user session
  UserSession? get currentUser => _currentUser;

  /// Get current username
  String? get currentUsername => _currentUser?.username;

  /// Check if user has active session
  bool get hasActiveSession => _currentUser != null;

  /// Get portfolio - returns current in-memory list
  /// Synchronous operation for simple UI binding
  List<PortfolioStock> getPortfolio() {
    print('Retrieved ${_portfolio.length} portfolio items from session');
    return List.from(
      _portfolio,
    ); // Return copy to prevent external modification
  }

  /// Get wishlist - returns current in-memory list
  /// Synchronous operation for simple UI binding
  List<String> getWishlist() {
    print('Retrieved ${_wishlist.length} wishlist items from session');
    return List.from(_wishlist); // Return copy to prevent external modification
  }

  /// Buy stock - core trading functionality
  /// Following lectures.md requirement: "Buy/Sell Orders: Execute market and limit orders"
  /// Handles both new purchases and existing stock updates
  Future<bool> buyStock(
    String symbol,
    double quantity,
    double purchasePrice,
  ) async {
    try {
      print(
        'Session: Buying $quantity shares of $symbol at \$${purchasePrice.toStringAsFixed(2)}',
      );

      // Check if stock already exists in portfolio
      final existingIndex = _portfolio.indexWhere(
        (stock) => stock.symbol.toUpperCase() == symbol.toUpperCase(),
      );

      if (existingIndex != -1) {
        // Stock exists - update quantity and recalculate average price
        final existing = _portfolio[existingIndex];
        final totalCost =
            (existing.quantity * existing.averagePurchasePrice) +
            (quantity * purchasePrice);
        final newQuantity = existing.quantity + quantity;
        final newAveragePrice = totalCost / newQuantity;

        // Update existing stock
        existing.quantity = newQuantity;
        existing.averagePurchasePrice = newAveragePrice;

        print(
          'Updated existing position: $newQuantity shares at avg \$${newAveragePrice.toStringAsFixed(2)}',
        );
      } else {
        // New stock - try to fetch company profile (with fallback)
        print('Fetching company profile for new stock: $symbol');

        String companyName = symbol.toUpperCase();
        String logoUrl = '';

        try {
          final companyProfile = await FinnhubService.getCompanyProfile(symbol);
          companyName = companyProfile?['name'] ?? symbol.toUpperCase();
          logoUrl = companyProfile?['logo'] ?? '';

          if (logoUrl.isNotEmpty) {
            print('Successfully fetched logo for $symbol');
          }
        } catch (e) {
          print('Failed to fetch company profile for $symbol: $e');
          // Continue with fallback values - don't block stock purchase
        }

        final newStock = PortfolioStock(
          symbol: symbol.toUpperCase(),
          companyName: companyName,
          logoUrl: logoUrl,
          quantity: quantity,
          averagePurchasePrice: purchasePrice,
        );

        _portfolio.add(newStock);
        print(
          'Created new position: $quantity shares at \$${purchasePrice.toStringAsFixed(2)} with logo: $logoUrl',
        );
      }

      return true;
    } catch (e) {
      print('Error buying stock: $e');
      return false;
    }
  }

  /// Sell stock - future implementation placeholder
  /// Following lectures.md requirement for trading functionality
  bool sellStock(String symbol, double quantity) {
    try {
      print('Session: Selling $quantity shares of $symbol');

      final existingIndex = _portfolio.indexWhere(
        (stock) => stock.symbol.toUpperCase() == symbol.toUpperCase(),
      );

      if (existingIndex == -1) {
        print('Stock not found in portfolio');
        return false;
      }

      final existing = _portfolio[existingIndex];

      if (existing.quantity < quantity) {
        print(
          'Insufficient shares: have ${existing.quantity}, trying to sell $quantity',
        );
        return false;
      }

      final newQuantity = existing.quantity - quantity;

      if (newQuantity <= 0) {
        // Remove stock completely if selling all shares
        _portfolio.removeAt(existingIndex);
        print('Sold all shares, removed from portfolio');
      } else {
        // Update quantity
        existing.quantity = newQuantity;
        print('Sold $quantity shares, $newQuantity remaining');
      }

      return true;
    } catch (e) {
      print('Error selling stock: $e');
      return false;
    }
  }

  /// Add stock to wishlist
  /// Following lectures.md requirement: "Watchlist: A customizable list of stocks"
  bool addToWishlist(String symbol) {
    try {
      final upperSymbol = symbol.toUpperCase();

      // Only add if not already in wishlist
      if (!_wishlist.contains(upperSymbol)) {
        _wishlist.add(upperSymbol);
        print('Added $upperSymbol to wishlist');
        return true;
      } else {
        print('$upperSymbol already in wishlist');
        return false;
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  /// Remove stock from wishlist
  bool removeFromWishlist(String symbol) {
    try {
      final upperSymbol = symbol.toUpperCase();

      if (_wishlist.remove(upperSymbol)) {
        print('Removed $upperSymbol from wishlist');
        return true;
      } else {
        print('$upperSymbol was not in wishlist');
        return false;
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  /// Check if stock is in wishlist
  bool isInWishlist(String symbol) {
    return _wishlist.contains(symbol.toUpperCase());
  }

  /// Get portfolio summary statistics
  Map<String, double> getPortfolioSummary() {
    try {
      if (_portfolio.isEmpty) {
        return {
          'totalValue': 0.0,
          'totalCost': 0.0,
          'totalProfitLoss': 0.0,
          'totalStocks': 0.0,
        };
      }

      double totalCost = 0.0;
      for (final stock in _portfolio) {
        totalCost += stock.quantity * stock.averagePurchasePrice;
      }

      return {
        'totalCost': totalCost,
        'totalStocks': _portfolio.length.toDouble(),
      };
    } catch (e) {
      print('Error getting portfolio summary: $e');
      return {
        'totalValue': 0.0,
        'totalCost': 0.0,
        'totalProfitLoss': 0.0,
        'totalStocks': 0.0,
      };
    }
  }

  /// Calculate total portfolio market value using real current prices
  /// This method fetches current prices from Finnhub API for accurate portfolio valuation
  Future<double> calculateTotalPortfolioValue() async {
    try {
      if (_portfolio.isEmpty) {
        return 0.0;
      }

      double totalValue = 0.0;

      for (final stock in _portfolio) {
        try {
          // Fetch current price from Finnhub API
          final quote = await FinnhubService.getQuote(stock.symbol);
          final currentPrice = quote?['c']?.toDouble() ?? 0.0;

          if (currentPrice > 0) {
            // Use the real current market price
            totalValue += stock.getTotalValue(currentPrice);
            print(
              '${stock.symbol}: ${stock.quantity} shares × \$${currentPrice.toStringAsFixed(2)} = \$${stock.getTotalValue(currentPrice).toStringAsFixed(2)}',
            );
          } else {
            print('Warning: Could not get current price for ${stock.symbol}');
          }
        } catch (e) {
          print('Error fetching price for ${stock.symbol}: $e');
        }
      }

      print('Total portfolio value: \$${totalValue.toStringAsFixed(2)}');
      return totalValue;
    } catch (e) {
      print('Error calculating total portfolio value: $e');
      return 0.0;
    }
  }

  /// Calculate total portfolio profit/loss using real current prices
  /// Returns both absolute profit/loss amount and percentage
  Future<Map<String, double>> calculatePortfolioProfitLoss() async {
    try {
      if (_portfolio.isEmpty) {
        return {'amount': 0.0, 'percentage': 0.0};
      }

      double totalCurrentValue = 0.0;
      double totalCostBasis = 0.0;

      for (final stock in _portfolio) {
        try {
          // Fetch current price from Finnhub API
          final quote = await FinnhubService.getQuote(stock.symbol);
          final currentPrice = quote?['c']?.toDouble() ?? 0.0;

          if (currentPrice > 0) {
            // Calculate current value and cost basis
            final currentValue = stock.getTotalValue(currentPrice);
            final costBasis = stock.quantity * stock.averagePurchasePrice;

            totalCurrentValue += currentValue;
            totalCostBasis += costBasis;

            print(
              '${stock.symbol}: Current \$${currentValue.toStringAsFixed(2)} vs Cost \$${costBasis.toStringAsFixed(2)}',
            );
          }
        } catch (e) {
          print('Error fetching price for ${stock.symbol}: $e');
        }
      }

      final profitLoss = totalCurrentValue - totalCostBasis;
      final profitLossPercentage = totalCostBasis > 0
          ? (profitLoss / totalCostBasis) * 100
          : 0.0;

      print(
        'Portfolio P&L: \$${profitLoss.toStringAsFixed(2)} (${profitLossPercentage.toStringAsFixed(2)}%)',
      );

      return {'amount': profitLoss, 'percentage': profitLossPercentage};
    } catch (e) {
      print('Error calculating portfolio profit/loss: $e');
      return {'amount': 0.0, 'percentage': 0.0};
    }
  }

  /// Fetch user's location and save detected country
  /// Following Lectures.md principle: simple integration with location service
  Future<String> fetchAndSaveLocation() async {
    try {
      print('SessionManager: Fetching user location...');

      if (_currentUser == null) {
        print('SessionManager: No active user session');
        throw Exception('No active user session');
      }

      // Use LocationService to get country
      final locationService = LocationService();

      print('SessionManager: Calling LocationService.getCountry()...');
      final countryCode = await locationService.getCountry();

      // Validate country code
      if (countryCode.isEmpty) {
        throw Exception('Invalid country code received');
      }

      // Save to current user session
      _currentUser!.detectedCountry = countryCode;

      print('SessionManager: Location saved successfully: $countryCode');
      return countryCode;
    } catch (e) {
      print('SessionManager: Error fetching and saving location: $e');

      // Ensure we have a clean error message
      if (e is Exception) {
        rethrow; // Pass Exception as-is
      } else {
        // Wrap other errors in Exception
        throw Exception('Unexpected error while getting location: $e');
      }
    }
  }

  /// Get detected country from current session
  String? getDetectedCountry() {
    return _currentUser?.detectedCountry;
  }

  /// Clear all session data (for testing/reset purposes)
  void clearAllData() {
    print('Clearing all session data');
    _portfolio.clear();
    _wishlist.clear();
    print('All session data cleared');
  }

  /// Debug method to print current session state
  void printSessionState() {
    print('Session State:');
    print('  User: ${_currentUser?.username ?? 'None'}');
    print('  Portfolio: ${_portfolio.length} stocks');
    print('  Wishlist: ${_wishlist.length} stocks');

    for (final stock in _portfolio) {
      print(
        '    ${stock.symbol}: ${stock.quantity} shares @ \$${stock.averagePurchasePrice.toStringAsFixed(2)}',
      );
    }

    for (final symbol in _wishlist) {
      print('    $symbol');
    }
  }
}
