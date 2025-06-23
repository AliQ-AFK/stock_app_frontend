import 'dart:math';

/// Represents stock information with mock data
///
/// This class stores comprehensive stock market data including pricing,
/// volume, and market capitalization information.
class Stock {
  /// Unique identifier for the stock
  String stockID;

  /// Stock symbol (e.g., AAPL, GOOGL)
  String symbol;

  /// Company name
  String company;

  /// Stock exchange where the stock is traded
  String exchange;

  /// Current stock price
  double currentPrice;

  /// Previous closing price
  double previousClose;

  /// Opening price for the current trading day
  double openPrice;

  /// Highest price reached during the current trading day
  double dayHigh;

  /// Lowest price reached during the current trading day
  double dayLow;

  /// Trading volume (number of shares traded)
  double volume;

  /// Market capitalization of the company
  double marketCap;

  /// Last update timestamp for the stock data
  DateTime lastUpdate;

  /// Creates a new Stock instance
  ///
  /// [stockID] - Unique identifier for the stock
  /// [symbol] - Stock symbol
  /// [company] - Company name
  /// [exchange] - Stock exchange
  /// [currentPrice] - Current stock price
  /// [previousClose] - Previous closing price
  /// [openPrice] - Opening price
  /// [dayHigh] - Day's high price
  /// [dayLow] - Day's low price
  /// [volume] - Trading volume
  /// [marketCap] - Market capitalization
  /// [lastUpdate] - Optional last update time, defaults to current time
  Stock({
    required this.stockID,
    required this.symbol,
    required this.company,
    required this.exchange,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.marketCap,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  /// Calculates the absolute price change from previous close
  ///
  /// Returns the difference between current price and previous close
  double calculateChange() {
    return currentPrice - previousClose;
  }

  /// Calculates the percentage price change from previous close
  ///
  /// Returns the percentage change as a double value
  double calculateChangePercent() {
    return ((currentPrice - previousClose) / previousClose) * 100;
  }

  /// Simulates random price movement for demo purposes
  ///
  /// Updates the current price with a random change between -1% and +1%
  void simulatePriceChange() {
    Random random = Random();
    double change = (random.nextDouble() - 0.5) * 2; // -1% to +1%
    currentPrice = currentPrice * (1 + change / 100);
    lastUpdate = DateTime.now();
  }
}
