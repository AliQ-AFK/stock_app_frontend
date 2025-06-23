import '../models/watchlist.dart';
import 'stock_data_service.dart';

/// Manages user watchlists
///
/// This service provides watchlist management functionality including
/// creating, updating, and managing watched stocks for users.
class WatchlistService {
  /// Static storage for watchlists
  static final Map<String, Watchlist> _watchlists = {};

  /// Initialize demo data
  ///
  /// Creates sample watchlists with stocks for demonstration purposes
  static void initializeDemoData() {
    final watchlist1 = Watchlist(
      watchlistID: "w1",
      userID: "1",
      name: "Tech Stocks",
    );

    // Add some stocks to watchlist (we'll update stock references later)
    StockDataService.getStockByID("2").then((stock) {
      if (stock != null) watchlist1.addStock("2", stock); // GOOGL
    });

    StockDataService.getStockByID("5").then((stock) {
      if (stock != null) watchlist1.addStock("5", stock); // TSLA
    });

    _watchlists["1"] = watchlist1;
  }

  /// Retrieves a user's watchlist
  ///
  /// [userID] - ID of the user whose watchlist to retrieve
  /// Returns the user's watchlist or null if not found
  static Future<Watchlist?> getUserWatchlist(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _watchlists[userID];
  }

  /// Creates a new watchlist for a user
  ///
  /// [userID] - ID of the user to create watchlist for
  /// [name] - Name of the watchlist
  /// Returns the created watchlist
  static Future<Watchlist> createWatchlist(String userID, String name) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = Watchlist(
      watchlistID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      name: name,
    );
    _watchlists[userID] = watchlist;
    return watchlist;
  }

  /// Adds a stock to a user's watchlist
  ///
  /// [userID] - ID of the user
  /// [stockID] - ID of the stock to add
  static Future<void> addToWatchlist(String userID, String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = _watchlists[userID];
    final stock = await StockDataService.getStockByID(stockID);

    if (watchlist != null && stock != null) {
      watchlist.addStock(stockID, stock);
    }
  }

  /// Removes a stock from a user's watchlist
  ///
  /// [userID] - ID of the user
  /// [stockID] - ID of the stock to remove
  static Future<void> removeFromWatchlist(String userID, String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = _watchlists[userID];
    watchlist?.removeStock(stockID);
  }
}
