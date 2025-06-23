import '../models/stock.dart';

/// Provides mock stock data
///
/// This service manages static stock market data for educational purposes,
/// providing search and retrieval functionality with simulated price movements.
class StockDataService {
  /// Static mock stock data
  static final List<Stock> _stocks = [
    Stock(
      stockID: "1",
      symbol: "AAPL",
      company: "Apple Inc.",
      exchange: "NASDAQ",
      currentPrice: 150.25,
      previousClose: 148.50,
      openPrice: 149.00,
      dayHigh: 151.00,
      dayLow: 148.25,
      volume: 75000000,
      marketCap: 2500000000000,
    ),
    Stock(
      stockID: "2",
      symbol: "GOOGL",
      company: "Alphabet Inc.",
      exchange: "NASDAQ",
      currentPrice: 2750.80,
      previousClose: 2725.50,
      openPrice: 2730.00,
      dayHigh: 2760.00,
      dayLow: 2720.00,
      volume: 1200000,
      marketCap: 1800000000000,
    ),
    Stock(
      stockID: "3",
      symbol: "MSFT",
      company: "Microsoft Corporation",
      exchange: "NASDAQ",
      currentPrice: 305.50,
      previousClose: 302.00,
      openPrice: 303.00,
      dayHigh: 307.00,
      dayLow: 301.50,
      volume: 22000000,
      marketCap: 2300000000000,
    ),
    Stock(
      stockID: "4",
      symbol: "AMZN",
      company: "Amazon.com Inc.",
      exchange: "NASDAQ",
      currentPrice: 3320.00,
      previousClose: 3300.00,
      openPrice: 3305.00,
      dayHigh: 3335.00,
      dayLow: 3295.00,
      volume: 3500000,
      marketCap: 1700000000000,
    ),
    Stock(
      stockID: "5",
      symbol: "TSLA",
      company: "Tesla Inc.",
      exchange: "NASDAQ",
      currentPrice: 875.50,
      previousClose: 860.00,
      openPrice: 865.00,
      dayHigh: 885.00,
      dayLow: 855.00,
      volume: 18000000,
      marketCap: 900000000000,
    ),
  ];

  /// Retrieves a stock by its symbol
  ///
  /// [symbol] - Stock symbol to search for
  /// Returns the stock if found, null otherwise
  static Future<Stock?> getStockBySymbol(String symbol) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _stocks.firstWhere((s) => s.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  /// Retrieves a stock by its ID
  ///
  /// [stockID] - Stock ID to search for
  /// Returns the stock if found, null otherwise
  static Future<Stock?> getStockByID(String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _stocks.firstWhere((s) => s.stockID == stockID);
    } catch (e) {
      return null;
    }
  }

  /// Retrieves all available stocks
  ///
  /// Returns a list of all stocks
  static Future<List<Stock>> getAllStocks() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_stocks);
  }

  /// Searches for stocks by query string
  ///
  /// [query] - Search query to match against symbol or company name
  /// Returns a list of matching stocks
  static Future<List<Stock>> searchStocks(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _stocks
        .where(
          (stock) =>
              stock.symbol.toLowerCase().contains(lowercaseQuery) ||
              stock.company.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Simulates price changes for all stocks
  ///
  /// Updates the current prices of all stocks with random movements
  static void simulatePriceChanges() {
    for (var stock in _stocks) {
      stock.simulatePriceChange();
    }
  }
}
