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
      symbol: "TSLA",
      company: "Tesla Inc.",
      exchange: "NASDAQ",
      currentPrice: 220.45,
      previousClose: 203.50,
      openPrice: 205.00,
      dayHigh: 225.00,
      dayLow: 202.00,
      volume: 18000000,
      marketCap: 900000000000,
    ),
    Stock(
      stockID: "2",
      symbol: "AAPL",
      company: "Apple Inc.",
      exchange: "NASDAQ",
      currentPrice: 175.80,
      previousClose: 170.33,
      openPrice: 171.00,
      dayHigh: 176.50,
      dayLow: 169.80,
      volume: 75000000,
      marketCap: 2500000000000,
    ),
    Stock(
      stockID: "3",
      symbol: "NVDA",
      company: "NVIDIA Corporation",
      exchange: "NASDAQ",
      currentPrice: 485.20,
      previousClose: 461.25,
      openPrice: 463.00,
      dayHigh: 490.00,
      dayLow: 460.50,
      volume: 42000000,
      marketCap: 1200000000000,
    ),
    Stock(
      stockID: "4",
      symbol: "AMD",
      company: "Advanced Micro Devices Inc.",
      exchange: "NASDAQ",
      currentPrice: 142.85,
      previousClose: 136.35,
      openPrice: 137.00,
      dayHigh: 145.00,
      dayLow: 135.80,
      volume: 28000000,
      marketCap: 230000000000,
    ),
    Stock(
      stockID: "5",
      symbol: "META",
      company: "Meta Platforms Inc.",
      exchange: "NASDAQ",
      currentPrice: 332.15,
      previousClose: 306.25,
      openPrice: 308.00,
      dayHigh: 335.00,
      dayLow: 305.50,
      volume: 32000000,
      marketCap: 840000000000,
    ),
    Stock(
      stockID: "6",
      symbol: "GOOGL",
      company: "Alphabet Inc.",
      exchange: "NASDAQ",
      currentPrice: 142.80,
      previousClose: 138.50,
      openPrice: 139.00,
      dayHigh: 144.00,
      dayLow: 137.25,
      volume: 12000000,
      marketCap: 1800000000000,
    ),
    Stock(
      stockID: "7",
      symbol: "MSFT",
      company: "Microsoft Corporation",
      exchange: "NASDAQ",
      currentPrice: 378.50,
      previousClose: 365.00,
      openPrice: 366.00,
      dayHigh: 380.00,
      dayLow: 364.50,
      volume: 22000000,
      marketCap: 2300000000000,
    ),
    Stock(
      stockID: "8",
      symbol: "AMZN",
      company: "Amazon.com Inc.",
      exchange: "NASDAQ",
      currentPrice: 156.20,
      previousClose: 151.00,
      openPrice: 152.00,
      dayHigh: 158.00,
      dayLow: 150.50,
      volume: 35000000,
      marketCap: 1700000000000,
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
