import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/buy_stock_screen.dart';
import 'package:stock_app_frontend/widgets/simple_stock_chart.dart';

/// Stock Detail Screen with live Finnhub API data
///
/// Following Lectures.md principles: "keep it simple" and "core features first"
/// Clean, step-by-step implementation as requested
class StockDetailScreen extends StatefulWidget {
  final String symbol;
  final String? companyName;

  const StockDetailScreen({Key? key, required this.symbol, this.companyName})
    : super(key: key);

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  // Step 1: Initial Setup - State variables as requested
  bool isLoading = true;
  Map<String, dynamic>? quoteData;
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? financialData;

  // Chart data variables
  List<double>? chartDataPoints; // To hold the prices for the chart
  List<int>? chartTimestamps; // To hold the timestamps for the chart
  bool isChartLoading = true; // To show a loading indicator
  Color chartColor = Colors.grey; // A default color before data is loaded

  // Simple time range state - following Lectures.md "keep it simple"
  int _selectedDays = 90; // Default to 90 days

  // Watchlist functionality
  bool _isInWatchlist = false;
  final SessionManager _sessionManager = SessionManager();

  // Company Profile expansion state
  bool _isProfileExpanded = false;

  @override
  void initState() {
    super.initState();
    // Simplified initialization - following Lectures.md "keep it simple"
    _fetchStockDetails();
    _checkWatchlistStatus();
    _updateChart(_selectedDays); // Load default chart
  }

  /// Step 1: Create _fetchStockDetails function using Future.wait
  /// Following Lectures.md performance criteria: "API Response Time: Under 500ms"
  Future<void> _fetchStockDetails() async {
    try {
      print('Fetching stock details for ${widget.symbol}...');

      // Calculate timestamps for past 1 week (more likely to have data)
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(Duration(days: 7));
      final fromTimestamp = oneWeekAgo.millisecondsSinceEpoch ~/ 1000;
      final toTimestamp = now.millisecondsSinceEpoch ~/ 1000;

      // Step 1: Use Future.wait to call four Finnhub methods simultaneously
      final results = await Future.wait([
        FinnhubService.getStockQuote(
          widget.symbol,
        ), // For current price, day range, previous close
        FinnhubService.getCompanyProfile(
          widget.symbol,
        ), // For company name, market cap
        FinnhubService.getBasicFinancials(widget.symbol), // For P/E ratio
        FinnhubService.getStockCandles(
          symbol: widget.symbol,
          resolution: '60', // Hourly data (more likely to be available)
          from: fromTimestamp,
          to: toTimestamp,
        ), // For chart data
      ]);

      // Step 1: Store results in state variables
      final candleData = results[3];

      print('Debug: Raw candle data for ${widget.symbol}: $candleData');

      // Extract closing prices and timestamps from candle data
      List<double>? closingPrices;
      List<int>? timestamps;
      Color newChartColor = Colors.grey;

      if (candleData != null &&
          candleData['c'] != null &&
          candleData['c'] is List &&
          (candleData['c'] as List).isNotEmpty) {
        try {
          final closingList = candleData['c'] as List<dynamic>;
          final timestampList = candleData['t'] as List<dynamic>? ?? [];

          closingPrices = closingList
              .map((price) => (price as num).toDouble())
              .toList();

          timestamps = timestampList
              .map((timestamp) => (timestamp as num).toInt())
              .toList();

          print(
            'Debug: Successfully extracted ${closingPrices.length} real price points and ${timestamps.length} timestamps for ${widget.symbol}',
          );

          // Implement color logic: compare first and last price
          if (closingPrices.isNotEmpty) {
            final firstPrice = closingPrices.first;
            final lastPrice = closingPrices.last;

            print(
              'Debug: ${widget.symbol} - First: \$${firstPrice.toStringAsFixed(2)}, Last: \$${lastPrice.toStringAsFixed(2)}',
            );

            if (lastPrice > firstPrice) {
              newChartColor = Colors.green[400]!;
              print('Debug: ${widget.symbol} chart color: GREEN (up trend)');
            } else if (lastPrice < firstPrice) {
              newChartColor = Colors.red[400]!;
              print('Debug: ${widget.symbol} chart color: RED (down trend)');
            } else {
              newChartColor = Colors.white70;
              print('Debug: ${widget.symbol} chart color: WHITE (flat trend)');
            }
          }
        } catch (e) {
          print('Debug: Error processing candle data for ${widget.symbol}: $e');
          closingPrices = _generateMockChartData();
          timestamps = _generateMockTimestamps();
          newChartColor = _getMockChartColor();
        }
      } else {
        print(
          'Debug: No valid candle data for ${widget.symbol}, using realistic mock data',
        );
        // Create realistic mock data specific to this symbol
        closingPrices = _generateMockChartData();
        timestamps = _generateMockTimestamps();
        newChartColor = _getMockChartColor();
        print(
          'Debug: Generated ${closingPrices.length} mock points and ${timestamps?.length} timestamps for ${widget.symbol}',
        );
      }

      setState(() {
        quoteData = results[0];
        profileData = results[1];
        financialData = results[2];
        chartDataPoints = closingPrices;
        chartTimestamps = timestamps;
        chartColor = newChartColor;
        isLoading = false;
        isChartLoading = false;
      });

      print('Stock details and chart data fetched successfully');
    } catch (e) {
      print('Error fetching stock details: $e');
      setState(() {
        isLoading = false;
        isChartLoading = false;
      });
      // Show error to user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading stock data')));
    }
  }

  /// Helper method to safely find user's stock
  PortfolioStock? _findUserStock() {
    final portfolio = _sessionManager.getPortfolio();
    try {
      return portfolio.firstWhere(
        (stock) => stock.symbol.toUpperCase() == widget.symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if stock is in watchlist
  void _checkWatchlistStatus() {
    setState(() {
      _isInWatchlist = _sessionManager.isInWishlist(widget.symbol);
    });
  }

  /// Toggle stock in/out of watchlist
  void _toggleWatchlist() {
    if (_isInWatchlist) {
      _sessionManager.removeFromWishlist(widget.symbol);
    } else {
      _sessionManager.addToWishlist(widget.symbol);
    }
    _checkWatchlistStatus();
  }

  /// Simple chart update method - following Lectures.md "keep it simple"
  /// Uses appropriate resolution based on time range
  Future<void> _updateChart(int days) async {
    setState(() {
      isChartLoading = true;
    });

    try {
      // Calculate timestamps and choose appropriate resolution
      final now = DateTime.now();
      final fromDate = now.subtract(Duration(days: days));
      final fromTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
      final toTimestamp = now.millisecondsSinceEpoch ~/ 1000;

      // Choose resolution based on time range - following Lectures.md "keep it simple"
      String resolution;
      if (days == 1) {
        resolution = '60'; // 1 hour intervals for 1 day
      } else if (days <= 7) {
        resolution = 'D'; // Daily for 1 week
      } else {
        resolution = 'D'; // Daily for longer periods
      }

      // Fetch chart data with appropriate resolution
      final candleData = await FinnhubService.getStockCandles(
        symbol: widget.symbol,
        resolution: resolution,
        from: fromTimestamp,
        to: toTimestamp,
      );

      // Process chart data
      List<double>? closingPrices;
      List<int>? timestamps;
      Color newChartColor = Colors.grey;

      if (candleData != null &&
          candleData['c'] != null &&
          candleData['c'] is List &&
          (candleData['c'] as List).isNotEmpty) {
        final closingList = candleData['c'] as List<dynamic>;
        final timestampList = candleData['t'] as List<dynamic>? ?? [];

        closingPrices = closingList
            .map((price) => (price as num).toDouble())
            .toList();

        timestamps = timestampList
            .map((timestamp) => (timestamp as num).toInt())
            .toList();

        // Determine chart color based on trend
        if (closingPrices.isNotEmpty) {
          final firstPrice = closingPrices.first;
          final lastPrice = closingPrices.last;

          if (lastPrice > firstPrice) {
            newChartColor = Colors.green[400]!;
          } else if (lastPrice < firstPrice) {
            newChartColor = Colors.red[400]!;
          } else {
            newChartColor = Colors.white70;
          }
        }
      } else {
        // Use mock data if API fails
        closingPrices = _generateMockChartData();
        timestamps = _generateMockTimestamps();
        newChartColor = _getMockChartColor();
      }

      setState(() {
        chartDataPoints = closingPrices;
        chartTimestamps = timestamps;
        chartColor = newChartColor;
        isChartLoading = false;
      });

      print(
        'Chart updated for $days days with ${closingPrices?.length ?? 0} data points',
      );
    } catch (e) {
      print('Error updating chart: $e');
      setState(() {
        isChartLoading = false;
      });
    }
  }

  /// Generate mock timestamps for chart X-axis
  /// Following Lectures.md: "keep it simple" - basic timestamp generation
  List<int> _generateMockTimestamps() {
    final now = DateTime.now();
    final List<int> mockTimestamps = [];

    if (_selectedDays == 1) {
      // Generate hourly timestamps for 1 day (24 hours)
      for (int i = 23; i >= 0; i--) {
        final timestamp =
            now.subtract(Duration(hours: i)).millisecondsSinceEpoch ~/ 1000;
        mockTimestamps.add(timestamp);
      }
    } else {
      // Generate daily timestamps for longer periods
      for (int i = _selectedDays - 1; i >= 0; i--) {
        final timestamp =
            now.subtract(Duration(days: i)).millisecondsSinceEpoch ~/ 1000;
        mockTimestamps.add(timestamp);
      }
    }

    return mockTimestamps;
  }

  /// Generate realistic mock chart data for testing when API fails
  /// Following Lectures.md: "keep it simple" - basic mock data generation
  List<double> _generateMockChartData() {
    final currentPrice = quoteData?['c']?.toDouble() ?? 200.0;
    final List<double> mockData = [];

    // Use symbol hash to create different patterns for different stocks
    final symbolHash = widget.symbol.hashCode.abs();

    // Create stock-specific starting point and volatility
    final startMultiplier = 0.85 + (symbolHash % 20) * 0.01; // 0.85 to 1.05
    final volatility = 0.02 + (symbolHash % 10) * 0.005; // 0.02 to 0.065
    final trendDirection =
        (symbolHash % 3) - 1; // -1, 0, or 1 for down, flat, up

    // Generate points based on selected time range
    double price = currentPrice * startMultiplier;
    final dataPoints = _selectedDays == 1
        ? 24
        : _selectedDays; // 24 hours for 1 day, otherwise days

    for (int i = 0; i < dataPoints; i++) {
      // Add trending component
      final trendComponent = trendDirection * (currentPrice * 0.001);

      // Add some realistic random variation using symbol hash
      final randomSeed = (symbolHash + i) % 100;
      final randomVariation =
          (randomSeed - 50) * (currentPrice * volatility) / 50;

      // Add some cyclical movement for realism
      final cyclical = math.sin(i * 0.3) * (currentPrice * 0.01);

      price += trendComponent + randomVariation + cyclical;

      // Ensure price doesn't go negative
      if (price < currentPrice * 0.5) {
        price = currentPrice * 0.5;
      }
      if (price > currentPrice * 1.5) {
        price = currentPrice * 1.5;
      }

      mockData.add(price);
    }

    return mockData;
  }

  /// Get chart color for mock data based on actual data trend
  Color _getMockChartColor() {
    final mockData = _generateMockChartData();
    if (mockData.isEmpty) return Colors.white70;

    final firstPrice = mockData.first;
    final lastPrice = mockData.last;

    print(
      'Debug: Mock data for ${widget.symbol} - First: \$${firstPrice.toStringAsFixed(2)}, Last: \$${lastPrice.toStringAsFixed(2)}',
    );

    if (lastPrice > firstPrice) {
      print('Debug: ${widget.symbol} mock chart color: GREEN (up trend)');
      return Colors.green[400]!;
    } else if (lastPrice < firstPrice) {
      print('Debug: ${widget.symbol} mock chart color: RED (down trend)');
      return Colors.red[400]!;
    } else {
      print('Debug: ${widget.symbol} mock chart color: WHITE (flat trend)');
      return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: _buildAppBar(brightness),
      body: Column(
        children: [
          // Step 1: Show loading indicator if isLoading is true
          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildContent(brightness)),
          _buildTradingButtons(brightness),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// App bar with company name and watchlist toggle
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.getText(brightness)),
        onPressed: () => Navigator.pop(context),
      ),
      // Step 2: Connect Title to profileData["name"] with logo
      title: Row(
        children: [
          // Company logo
          if (profileData?['logo'] != null && profileData!['logo'].isNotEmpty)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  profileData!['logo'],
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.getWidgetBG(brightness),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppColors.getText(brightness),
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
          // Company name
          Expanded(
            child: Text(
              profileData?['name'] ?? widget.companyName ?? widget.symbol,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _toggleWatchlist,
          icon: Icon(
            _isInWatchlist ? Icons.favorite : Icons.favorite_border,
            color: _isInWatchlist ? Colors.red : AppColors.getText(brightness),
          ),
        ),
      ],
    );
  }

  /// Main content with all sections
  Widget _buildContent(Brightness brightness) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceChart(brightness),
          SizedBox(height: 24),
          _buildMyStockSection(brightness),
          SizedBox(height: 24),
          _buildStockStats(brightness),
          SizedBox(height: 24),
          _buildMarketStats(brightness),
          SizedBox(height: 24),
          _buildCompanyProfile(brightness),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Price Chart section
  Widget _buildPriceChart(Brightness brightness) {
    // Get current price from quoteData
    final currentPrice = quoteData?['c']?.toDouble() ?? 0.0;
    final change = quoteData?['d']?.toDouble() ?? 0.0;
    final changePercent = quoteData?['dp']?.toDouble() ?? 0.0;
    final isPositive = change >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getWidgetBG(brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and change
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.getText(brightness),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Interactive time period buttons - following Lectures.md "keep it simple"
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildTimeRangeButtons(brightness),
          ),
          SizedBox(height: 16),
          // Chart - show loading indicator or actual chart
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.getBG(brightness),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isChartLoading
                ? Center(child: CircularProgressIndicator())
                : (chartDataPoints != null && chartDataPoints!.isNotEmpty)
                ? SimpleStockChart(
                    dataPoints: chartDataPoints!,
                    timestamps: chartTimestamps,
                    lineColor: chartColor,
                    brightness: brightness,
                  )
                : Center(
                    child: Text(
                      'Chart data unavailable',
                      style: TextStyle(
                        color: AppColors.getText(brightness).withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// My Stock section
  Widget _buildMyStockSection(Brightness brightness) {
    // Step 3: Get user's shares from SessionManager
    final userStock = _findUserStock();

    // Step 2: Get day range from quoteData
    final dayHigh = quoteData?['h']?.toDouble() ?? 0.0;
    final dayLow = quoteData?['l']?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Stock',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            // Shares card
            Expanded(
              child: _buildStatCard(
                'Shares',
                // Step 3: Show user's quantity from SessionManager
                userStock?.quantity.toStringAsFixed(0) ?? '0',
                brightness,
              ),
            ),
            SizedBox(width: 12),
            // Day range card
            Expanded(
              child: _buildStatCard(
                'Day range',
                // Step 2: Use quoteData["h"] and quoteData["l"]
                '\$${dayLow.toStringAsFixed(2)} - \$${dayHigh.toStringAsFixed(2)}',
                brightness,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Stock Stats section
  Widget _buildStockStats(Brightness brightness) {
    // Step 2: Get previous close from quoteData
    final previousClose = quoteData?['pc']?.toDouble() ?? 0.0;

    // Step 3: Calculate total returns
    final userStock = _findUserStock();

    double totalReturns = 0.0;
    if (userStock != null && quoteData != null) {
      final currentPrice = quoteData!['c']?.toDouble() ?? 0.0;
      // Step 3: Calculate (current price * quantity) - (purchase price * quantity)
      totalReturns =
          (currentPrice * userStock.quantity) -
          (userStock.averagePurchasePrice * userStock.quantity);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            // Previous close card
            Expanded(
              child: _buildStatCard(
                'Previous close',
                // Step 2: Use quoteData["pc"]
                '\$${previousClose.toStringAsFixed(2)}',
                brightness,
              ),
            ),
            SizedBox(width: 12),
            // Total returns card
            Expanded(
              child: _buildStatCard(
                'Total returns',
                // Step 3: Show calculated total returns
                '\$${totalReturns.toStringAsFixed(2)}',
                brightness,
                valueColor: totalReturns >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Market Stats section
  Widget _buildMarketStats(Brightness brightness) {
    // Step 2: Get market cap from profileData
    final marketCap = profileData?['marketCapitalization']?.toDouble() ?? 0.0;

    // Step 2: Get P/E ratio from financialData
    final peRatio =
        financialData?['metric']?['peNormalizedAnnual']?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            // Market cap card
            Expanded(
              child: _buildStatCard(
                'Market cap',
                // Step 2: Format market cap to be readable
                _formatMarketCap(marketCap),
                brightness,
              ),
            ),
            SizedBox(width: 12),
            // P/E ratio card
            Expanded(
              child: _buildStatCard(
                'Price-Earnings ratio',
                // Step 2: Use financialData P/E ratio
                peRatio > 0 ? peRatio.toStringAsFixed(2) : 'N/A',
                brightness,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Company Profile section with Read More/Show Less functionality
  Widget _buildCompanyProfile(Brightness brightness) {
    // Get company description from profileData
    final description =
        profileData?['description'] ?? 'No company description available.';
    final industry = profileData?['finnhubIndustry'] ?? 'N/A';
    final country = profileData?['country'] ?? 'N/A';
    final exchange = profileData?['exchange'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Company Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        SizedBox(height: 16),

        // Description with expandable functionality
        Text(
          description,
          maxLines: _isProfileExpanded
              ? null
              : 4, // Show 4 lines when collapsed, all when expanded
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.getText(brightness),
            height: 1.5,
            fontSize: 14,
          ),
        ),

        // Read More / Show Less button (only show if description is long enough)
        if (description.length >
            200) // Only show button for longer descriptions
          TextButton(
            onPressed: () {
              setState(() {
                _isProfileExpanded = !_isProfileExpanded;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isProfileExpanded ? 'Show Less' : 'Read More',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        SizedBox(height: 16),

        // Additional company information
        Row(
          children: [
            Expanded(child: _buildInfoItem('Industry', industry, brightness)),
            Expanded(child: _buildInfoItem('Country', country, brightness)),
          ],
        ),
        SizedBox(height: 8),
        _buildInfoItem('Exchange', exchange, brightness),
      ],
    );
  }

  /// Helper method to build stat cards
  Widget _buildStatCard(
    String title,
    String value,
    Brightness brightness, {
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getGreyBG(brightness),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.getText(brightness),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build info items
  Widget _buildInfoItem(String label, String value, Brightness brightness) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getText(brightness),
            ),
          ),
        ],
      ),
    );
  }

  /// Format market cap to be readable (e.g., in Trillions)
  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(2)}T';
    } else if (marketCap >= 1000) {
      return '\$${(marketCap / 1000).toStringAsFixed(2)}B';
    } else {
      return '\$${marketCap.toStringAsFixed(2)}M';
    }
  }

  /// Build interactive time range buttons - following Lectures.md "keep it simple"
  List<Widget> _buildTimeRangeButtons(Brightness brightness) {
    final buttonData = [
      {'label': '1D', 'days': 1},
      {'label': '1W', 'days': 7},
      {'label': '1M', 'days': 30},
      {'label': '3M', 'days': 90},
      {'label': '1Y', 'days': 365},
      {'label': 'ALL', 'days': 1095}, // 3 years for "ALL"
    ];

    return buttonData.map((button) {
      final label = button['label'] as String;
      final days = button['days'] as int;
      final isSelected = _selectedDays == days;

      return Padding(
        padding: EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedDays = days;
            });
            _updateChart(days);
          },
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.getText(brightness)
                  : AppColors.getText(brightness).withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Trading buttons at bottom
  Widget _buildTradingButtons(Brightness brightness) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSellStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sell',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleBuyStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Buy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle buy stock action
  void _handleBuyStock() async {
    final currentPrice = quoteData?['c']?.toDouble() ?? 0.0;

    if (currentPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to buy stock: Price data not available'),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          BuyStockScreen(symbol: widget.symbol, currentPrice: currentPrice),
    );

    // Refresh data after purchase
    if (result == true) {
      setState(() {
        // This will trigger a rebuild and show updated user stock data
      });
    }
  }

  /// Handle sell stock action (placeholder)
  void _handleSellStock() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sell functionality coming soon')));
  }
}
