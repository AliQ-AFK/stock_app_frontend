import 'stock_holding.dart';

/// Container for user's holdings
///
/// This class manages a collection of stock holdings and provides
/// calculated properties for portfolio performance and value.
class Portfolio {
  /// Unique identifier for the portfolio
  String portfolioID;

  /// ID of the user who owns this portfolio
  String userID;

  /// Name of the portfolio
  String name;

  /// List of stock holdings in this portfolio
  List<StockHolding> holdings;

  /// Date when the portfolio was created
  DateTime createdAt;

  /// Date when the portfolio was last updated
  DateTime lastUpdated;

  /// Creates a new Portfolio instance
  ///
  /// [portfolioID] - Unique identifier for the portfolio
  /// [userID] - ID of the user who owns this portfolio
  /// [name] - Name of the portfolio
  /// [holdings] - Optional list of holdings, defaults to empty list
  /// [createdAt] - Optional creation date, defaults to current time
  Portfolio({
    required this.portfolioID,
    required this.userID,
    required this.name,
    List<StockHolding>? holdings,
    DateTime? createdAt,
  }) : holdings = holdings ?? [],
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = DateTime.now();

  /// Calculates the total current market value of all holdings
  ///
  /// Returns the sum of current values of all holdings
  double get totalValue {
    return holdings.fold(0, (sum, holding) => sum + holding.currentValue);
  }

  /// Calculates the total cost basis of all holdings
  ///
  /// Returns the sum of total costs of all holdings
  double get totalCost {
    return holdings.fold(0, (sum, holding) => sum + holding.totalCost);
  }

  /// Calculates the total unrealized gain or loss
  ///
  /// Returns the difference between total value and total cost
  double get totalGainLoss {
    return totalValue - totalCost;
  }

  /// Calculates the total gain or loss percentage
  ///
  /// Returns the percentage gain/loss based on total cost
  double get totalGainLossPercent {
    return totalCost > 0 ? (totalGainLoss / totalCost) * 100 : 0;
  }

  /// Adds a new holding to the portfolio
  ///
  /// [holding] - The stock holding to add
  void addHolding(StockHolding holding) {
    holdings.add(holding);
    lastUpdated = DateTime.now();
  }

  /// Removes a holding from the portfolio by holding ID
  ///
  /// [holdingID] - ID of the holding to remove
  void removeHolding(String holdingID) {
    holdings.removeWhere((h) => h.holdingID == holdingID);
    lastUpdated = DateTime.now();
  }

  /// Retrieves a holding by stock ID
  ///
  /// [stockID] - ID of the stock to find
  /// Returns the holding if found, null otherwise
  StockHolding? getHolding(String stockID) {
    try {
      return holdings.firstWhere((h) => h.stockID == stockID);
    } catch (e) {
      return null;
    }
  }
}
