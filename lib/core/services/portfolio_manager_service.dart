import '../models/portfolio.dart';
import '../models/stock_holding.dart';
import 'stock_data_service.dart';

/// Manages user portfolios in memory
///
/// This service provides portfolio management functionality including
/// creating, updating, and managing stock holdings for users.
class PortfolioManagerService {
  /// Static storage for portfolios
  static final Map<String, Portfolio> _portfolios = {};

  /// Initialize with demo data
  ///
  /// Creates sample portfolios with holdings for demonstration purposes
  static void initializeDemoData() {
    // Create demo portfolio for user 1
    final portfolio1 = Portfolio(
      portfolioID: "p1",
      userID: "1",
      name: "Main Portfolio",
    );

    // Add some holdings (we'll update stock references later)
    portfolio1.addHolding(
      StockHolding(
        holdingID: "h1",
        portfolioID: "p1",
        stockID: "1", // TSLA
        quantity: 150,
        averagePurchasePrice: 195.00,
      ),
    );

    portfolio1.addHolding(
      StockHolding(
        holdingID: "h2",
        portfolioID: "p1",
        stockID: "2", // AAPL
        quantity: 200,
        averagePurchasePrice: 165.00,
      ),
    );

    portfolio1.addHolding(
      StockHolding(
        holdingID: "h3",
        portfolioID: "p1",
        stockID: "3", // NVDA
        quantity: 75,
        averagePurchasePrice: 450.00,
      ),
    );

    _portfolios["1"] = portfolio1;
  }

  /// Retrieves a user's portfolio
  ///
  /// [userID] - ID of the user whose portfolio to retrieve
  /// Returns the user's portfolio or null if not found
  static Future<Portfolio?> getUserPortfolio(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _portfolios[userID];
  }

  /// Creates a new portfolio for a user
  ///
  /// [userID] - ID of the user to create portfolio for
  /// [name] - Name of the portfolio
  /// Returns the created portfolio
  static Future<Portfolio> createPortfolio(String userID, String name) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = Portfolio(
      portfolioID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      name: name,
    );
    _portfolios[userID] = portfolio;
    return portfolio;
  }

  /// Adds a holding to a user's portfolio
  ///
  /// [userID] - ID of the user
  /// [holding] - Stock holding to add
  static Future<void> addHolding(String userID, StockHolding holding) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = _portfolios[userID];
    if (portfolio != null) {
      // Check if already holding this stock
      final existingHolding = portfolio.getHolding(holding.stockID);
      if (existingHolding != null) {
        existingHolding.addShares(
          holding.quantity,
          holding.averagePurchasePrice,
        );
      } else {
        portfolio.addHolding(holding);
      }
    }
  }

  /// Removes a holding from a user's portfolio
  ///
  /// [userID] - ID of the user
  /// [holdingID] - ID of the holding to remove
  static Future<void> removeHolding(String userID, String holdingID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = _portfolios[userID];
    portfolio?.removeHolding(holdingID);
  }

  /// Updates stock references in all holdings
  ///
  /// This method should be called after stock data is updated to ensure
  /// holdings have current stock information
  static void updateStockReferences() {
    for (var portfolio in _portfolios.values) {
      for (var holding in portfolio.holdings) {
        // Find the stock by ID and update the reference
        StockDataService.getStockByID(holding.stockID).then((stock) {
          holding.stock = stock;
        });
      }
    }
  }
}
