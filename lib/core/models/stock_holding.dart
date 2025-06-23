import 'stock.dart';

/// Represents user's position in a stock
///
/// This class tracks the quantity, purchase price, and performance
/// of a specific stock holding in a user's portfolio.
class StockHolding {
  /// Unique identifier for this holding
  String holdingID;

  /// ID of the portfolio this holding belongs to
  String portfolioID;

  /// ID of the stock being held
  String stockID;

  /// Number of shares owned
  double quantity;

  /// Average purchase price per share
  double averagePurchasePrice;

  /// Date of first purchase
  DateTime firstPurchaseDate;

  /// Reference to the stock object for current price information
  Stock? stock;

  /// Creates a new StockHolding instance
  ///
  /// [holdingID] - Unique identifier for this holding
  /// [portfolioID] - ID of the portfolio this holding belongs to
  /// [stockID] - ID of the stock being held
  /// [quantity] - Number of shares owned
  /// [averagePurchasePrice] - Average purchase price per share
  /// [firstPurchaseDate] - Optional first purchase date, defaults to current time
  /// [stock] - Optional reference to the stock object
  StockHolding({
    required this.holdingID,
    required this.portfolioID,
    required this.stockID,
    required this.quantity,
    required this.averagePurchasePrice,
    DateTime? firstPurchaseDate,
    this.stock,
  }) : firstPurchaseDate = firstPurchaseDate ?? DateTime.now();

  /// Calculates the total cost basis of this holding
  ///
  /// Returns the total amount paid for all shares (quantity × average price)
  double get totalCost {
    return quantity * averagePurchasePrice;
  }

  /// Calculates the current market value of this holding
  ///
  /// Returns the current value based on latest stock price
  double get currentValue {
    return stock != null ? quantity * stock!.currentPrice : 0;
  }

  /// Calculates the unrealized gain or loss
  ///
  /// Returns the difference between current value and total cost
  double get unrealizedGainLoss {
    return currentValue - totalCost;
  }

  /// Calculates the unrealized gain or loss percentage
  ///
  /// Returns the percentage gain/loss based on total cost
  double get unrealizedGainLossPercent {
    return totalCost > 0 ? (unrealizedGainLoss / totalCost) * 100 : 0;
  }

  /// Adds more shares to this holding with average price calculation
  ///
  /// [newQuantity] - Number of new shares to add
  /// [purchasePrice] - Price paid per new share
  void addShares(double newQuantity, double purchasePrice) {
    double totalPreviousCost = totalCost;
    double newCost = newQuantity * purchasePrice;
    quantity += newQuantity;
    averagePurchasePrice = (totalPreviousCost + newCost) / quantity;
  }

  /// Removes shares from this holding
  ///
  /// [sellQuantity] - Number of shares to remove
  void removeShares(double sellQuantity) {
    if (sellQuantity <= quantity) {
      quantity -= sellQuantity;
    }
  }
}
