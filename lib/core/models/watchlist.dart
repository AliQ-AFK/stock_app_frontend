import 'watchlist_item.dart';
import 'stock.dart';

/// User's favorite stocks list
///
/// This class manages a collection of stocks that the user wants to monitor,
/// providing functionality to add, remove, and organize watchlist items.
class Watchlist {
  /// Unique identifier for the watchlist
  String watchlistID;

  /// ID of the user who owns this watchlist
  String userID;

  /// Name of the watchlist
  String name;

  /// List of items in this watchlist
  List<WatchlistItem> items;

  /// Date when the watchlist was created
  DateTime createdDate;

  /// Date when the watchlist was last modified
  DateTime lastModified;

  /// Creates a new Watchlist instance
  ///
  /// [watchlistID] - Unique identifier for the watchlist
  /// [userID] - ID of the user who owns this watchlist
  /// [name] - Name of the watchlist, defaults to "My Watchlist"
  /// [items] - Optional list of items, defaults to empty list
  /// [createdDate] - Optional creation date, defaults to current time
  Watchlist({
    required this.watchlistID,
    required this.userID,
    this.name = "My Watchlist",
    List<WatchlistItem>? items,
    DateTime? createdDate,
  }) : items = items ?? [],
       createdDate = createdDate ?? DateTime.now(),
       lastModified = DateTime.now();

  /// Adds a stock to the watchlist
  ///
  /// [stockID] - ID of the stock to add
  /// [stock] - Stock object to add
  void addStock(String stockID, Stock stock) {
    final newItem = WatchlistItem(
      itemID: DateTime.now().millisecondsSinceEpoch.toString(),
      watchlistID: watchlistID,
      stockID: stockID,
      position: items.length,
      stock: stock,
    );
    items.add(newItem);
    lastModified = DateTime.now();
  }

  /// Removes a stock from the watchlist
  ///
  /// [stockID] - ID of the stock to remove
  void removeStock(String stockID) {
    items.removeWhere((item) => item.stockID == stockID);
    _reorderItems();
    lastModified = DateTime.now();
  }

  /// Reorders the position values of all items after removal
  void _reorderItems() {
    for (int i = 0; i < items.length; i++) {
      items[i].position = i;
    }
  }

  /// Checks if the watchlist contains a specific stock
  ///
  /// [stockID] - ID of the stock to check
  /// Returns true if the stock is in the watchlist
  bool containsStock(String stockID) {
    return items.any((item) => item.stockID == stockID);
  }
}
