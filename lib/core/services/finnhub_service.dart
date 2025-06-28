import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

/// Service class for handling Finnhub API operations
///
/// This service provides methods to fetch real-time stock data,
/// company information, and other financial data from Finnhub API
class FinnhubService {
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  /// Get the API key from environment variables
  static String get _apiKey => dotenv.env['FINNHUB_API_KEY'] ?? '';

  /// Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Get current stock price quote
  ///
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'GOOGL')
  /// Returns a map with current price data
  static Future<Map<String, dynamic>?> getStockQuote(String symbol) async {
    try {
      final url = '$_baseUrl/quote?symbol=$symbol&token=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching stock quote: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getStockQuote: $e');
      return null;
    }
  }

  /// Get company profile information
  ///
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'GOOGL')
  /// Returns a map with company information
  static Future<Map<String, dynamic>?> getCompanyProfile(String symbol) async {
    try {
      final url = '$_baseUrl/stock/profile2?symbol=$symbol&token=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        // Rate limit or quota exceeded - don't spam logs
        throw Exception('API rate limit exceeded (403)');
      } else {
        print('Error fetching company profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        // Re-throw 403 errors so they can be handled specifically
        rethrow;
      }
      print('Exception in getCompanyProfile: $e');
      return null;
    }
  }

  /// Get stock candle data for charts
  ///
  /// [symbol] - Stock symbol
  /// [resolution] - Resolution ('1', '5', '15', '30', '60', 'D', 'W', 'M')
  /// [from] - From timestamp (Unix timestamp)
  /// [to] - To timestamp (Unix timestamp)
  /// Returns candle data for charting
  static Future<Map<String, dynamic>?> getStockCandles({
    required String symbol,
    required String resolution,
    required int from,
    required int to,
  }) async {
    try {
      final url =
          '$_baseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching stock candles: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getStockCandles: $e');
      return null;
    }
  }

  /// Searches for stocks matching the query.
  ///
  /// [query] - Search query (symbol or company name)
  /// Returns a map with search results from Finnhub API
  /// Throws an Exception if the request fails
  static Future<Map<String, dynamic>> searchStocks(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?q=$query&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search stocks');
    }
  }

  /// Fetches real-time quote data for a symbol.
  ///
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'GOOGL')
  /// Returns current price data including previous close, high, low, etc.
  static Future<Map<String, dynamic>> getQuote(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quote data');
    }
  }

  /// Fetches basic financial metrics for a company.
  ///
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'GOOGL')
  /// Returns financial metrics including P/E ratio, market cap, etc.
  static Future<Map<String, dynamic>> getBasicFinancials(String symbol) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/stock/metric?symbol=$symbol&metric=all&token=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load basic financials');
    }
  }

  /// Fetches company news for the last 7 days.
  ///
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'GOOGL')
  /// Returns a list of recent news articles
  static Future<List<dynamic>> getCompanyNews(String symbol) async {
    final to = DateTime.now();
    final from = to.subtract(
      const Duration(days: 7),
    ); // News from the last 7 days
    final formattedTo = DateFormat('yyyy-MM-dd').format(to);
    final formattedFrom = DateFormat('yyyy-MM-dd').format(from);

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/company-news?symbol=$symbol&from=$formattedFrom&to=$formattedTo&token=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load company news');
    }
  }

  /// Get market news
  ///
  /// [category] - News category ('general', 'forex', 'crypto', 'merger')
  /// [minId] - Minimum news ID for pagination
  /// Returns a list of news articles
  static Future<List<dynamic>?> getMarketNews({
    String category = 'general',
    String? minId,
  }) async {
    try {
      String url = '$_baseUrl/news?category=$category&token=$_apiKey';
      if (minId != null) {
        url += '&minId=$minId';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching market news: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getMarketNews: $e');
      return null;
    }
  }

  /// Check if API key is configured
  static bool isApiKeyConfigured() {
    return _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';
  }

  /// Get API usage status
  static Future<Map<String, dynamic>?> getApiUsage() async {
    try {
      final url = '$_baseUrl/api-usage?token=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching API usage: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getApiUsage: $e');
      return null;
    }
  }
}
