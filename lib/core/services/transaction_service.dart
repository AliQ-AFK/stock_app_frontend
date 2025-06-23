import '../models/transaction.dart';
import '../models/stock_holding.dart';
import '../models/enums/transaction_enums.dart';
import 'stock_data_service.dart';
import 'portfolio_manager_service.dart';

/// Records and manages transactions
///
/// This service handles the creation and management of buy/sell transactions
/// and updates portfolios accordingly.
class TransactionService {
  /// Static storage for transactions
  static final List<Transaction> _transactions = [];

  /// Creates a buy transaction
  ///
  /// [userID] - ID of the user making the purchase
  /// [portfolioID] - ID of the portfolio to update
  /// [stockID] - ID of the stock being purchased
  /// [quantity] - Number of shares to buy
  /// [price] - Price per share
  /// Returns the created transaction
  static Future<Transaction> createBuyTransaction({
    required String userID,
    required String portfolioID,
    required String stockID,
    required double quantity,
    required double price,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final transaction = Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      portfolioID: portfolioID,
      stockID: stockID,
      type: TransactionType.buy,
      quantity: quantity,
      price: price,
      commission: 4.95, // Fixed commission
    );

    _transactions.add(transaction);

    // Update portfolio
    final stock = await StockDataService.getStockByID(stockID);
    if (stock != null) {
      final holding = StockHolding(
        holdingID: DateTime.now().millisecondsSinceEpoch.toString(),
        portfolioID: portfolioID,
        stockID: stockID,
        quantity: quantity,
        averagePurchasePrice: price,
        stock: stock,
      );
      await PortfolioManagerService.addHolding(userID, holding);
    }

    return transaction;
  }

  /// Creates a sell transaction
  ///
  /// [userID] - ID of the user making the sale
  /// [portfolioID] - ID of the portfolio to update
  /// [stockID] - ID of the stock being sold
  /// [quantity] - Number of shares to sell
  /// [price] - Price per share
  /// Returns the created transaction
  static Future<Transaction> createSellTransaction({
    required String userID,
    required String portfolioID,
    required String stockID,
    required double quantity,
    required double price,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final transaction = Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      portfolioID: portfolioID,
      stockID: stockID,
      type: TransactionType.sell,
      quantity: quantity,
      price: price,
      commission: 4.95,
    );

    _transactions.add(transaction);

    // Update portfolio
    final portfolio = await PortfolioManagerService.getUserPortfolio(userID);
    if (portfolio != null) {
      final holding = portfolio.getHolding(stockID);
      if (holding != null) {
        holding.removeShares(quantity);
        if (holding.quantity <= 0) {
          await PortfolioManagerService.removeHolding(
            userID,
            holding.holdingID,
          );
        }
      }
    }

    return transaction;
  }

  /// Retrieves all transactions for a user
  ///
  /// [userID] - ID of the user whose transactions to retrieve
  /// Returns a list of transactions sorted by date (newest first)
  static Future<List<Transaction>> getUserTransactions(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _transactions.where((t) => t.userID == userID).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }
}
