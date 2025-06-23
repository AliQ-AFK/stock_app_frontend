import 'stock.dart';

/// Individual entry in watchlist
///
/// This class represents a single stock entry in a user's watchlist
/// with optional price alert functionality.
class WatchlistItem {
  /// Unique identifier for this watchlist item
  String itemID;

  /// ID of the watchlist this item belongs to
  String watchlistID;

  /// ID of the stock being watched
  String stockID;

  /// Position/order of this item in the watchlist
  int position;

  /// Date when this item was added to the watchlist
  DateTime addedDate;

  /// Optional price alert threshold
  double? priceAlert;

  /// Reference to the stock object for current information
  Stock? stock;

  /// Creates a new WatchlistItem instance
  ///
  /// [itemID] - Unique identifier for this watchlist item
  /// [watchlistID] - ID of the watchlist this item belongs to
  /// [stockID] - ID of the stock being watched
  /// [position] - Position/order of this item in the watchlist
  /// [addedDate] - Optional date added, defaults to current time
  /// [priceAlert] - Optional price alert threshold
  /// [stock] - Optional reference to the stock object
  WatchlistItem({
    required this.itemID,
    required this.watchlistID,
    required this.stockID,
    required this.position,
    DateTime? addedDate,
    this.priceAlert,
    this.stock,
  }) : addedDate = addedDate ?? DateTime.now();

  /// Sets a price alert for this watchlist item
  ///
  /// [alertPrice] - The price threshold for the alert
  void setPriceAlert(double alertPrice) {
    priceAlert = alertPrice;
  }

  /// Checks if the price alert condition is met
  ///
  /// Returns true if the current stock price meets or exceeds the alert price
  bool checkPriceAlert() {
    if (priceAlert != null && stock != null) {
      return stock!.currentPrice >= priceAlert!;
    }
    return false;
  }
}
