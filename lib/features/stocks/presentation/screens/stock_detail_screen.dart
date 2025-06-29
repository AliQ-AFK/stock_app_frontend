import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/buy_stock_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/sell_stock_screen.dart';
import 'package:stock_app_frontend/widgets/simple_stock_chart.dart';
import 'package:stock_app_frontend/core/models/news_article.dart';

/// Stock Detail Screen with tabbed layout - Overview and News
///
/// Following Lectures.md principles: "keep it simple" and "core features first"
/// Clean, step-by-step implementation with DefaultTabController
class StockDetailScreen extends StatefulWidget {
  final String symbol;
  final String? companyName;

  const StockDetailScreen({Key? key, required this.symbol, this.companyName})
    : super(key: key);

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  // State variables for stock data
  bool isLoading = true;
  Map<String, dynamic>? quoteData;
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? financialData;

  // Chart data variables
  List<double>? chartDataPoints;
  List<int>? chartTimestamps;
  bool isChartLoading = true;
  Color chartColor = Colors.grey;

  // Simple time range state
  int _selectedDays = 90; // Default to 90 days

  // Watchlist functionality
  bool _isInWatchlist = false;
  final SessionManager _sessionManager = SessionManager();

  // Company Profile expansion state
  bool _isProfileExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchStockDetails();
    _checkWatchlistStatus();
    _updateChart(_selectedDays);
  }

  /// Fetch stock details using Future.wait for performance
  Future<void> _fetchStockDetails() async {
    try {
      print('Fetching stock details for ${widget.symbol}...');

      final now = DateTime.now();
      final oneWeekAgo = now.subtract(Duration(days: 7));
      final fromTimestamp = oneWeekAgo.millisecondsSinceEpoch ~/ 1000;
      final toTimestamp = now.millisecondsSinceEpoch ~/ 1000;

      final results = await Future.wait([
        FinnhubService.getStockQuote(widget.symbol),
        FinnhubService.getCompanyProfile(widget.symbol),
        FinnhubService.getBasicFinancials(widget.symbol),
        FinnhubService.getStockCandles(
          symbol: widget.symbol,
          resolution: '60',
          from: fromTimestamp,
          to: toTimestamp,
        ),
      ]);

      // Company profile data from Finnhub API (free tier)

      final candleData = results[3];

      // Process chart data
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
        } catch (e) {
          print('Error processing candle data: $e');
          closingPrices = _generateMockChartData();
          timestamps = _generateMockTimestamps();
          newChartColor = _getMockChartColor();
        }
      } else {
        closingPrices = _generateMockChartData();
        timestamps = _generateMockTimestamps();
        newChartColor = _getMockChartColor();
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

  /// Simple chart update method
  Future<void> _updateChart(int days) async {
    setState(() {
      isChartLoading = true;
    });

    try {
      final now = DateTime.now();
      final fromDate = now.subtract(Duration(days: days));
      final fromTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
      final toTimestamp = now.millisecondsSinceEpoch ~/ 1000;

      String resolution;
      if (days == 1) {
        resolution = '60';
      } else if (days <= 7) {
        resolution = 'D';
      } else {
        resolution = 'D';
      }

      final candleData = await FinnhubService.getStockCandles(
        symbol: widget.symbol,
        resolution: resolution,
        from: fromTimestamp,
        to: toTimestamp,
      );

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
    } catch (e) {
      print('Error updating chart: $e');
      setState(() {
        isChartLoading = false;
      });
    }
  }

  /// Generate mock timestamps for chart X-axis
  List<int> _generateMockTimestamps() {
    final now = DateTime.now();
    final List<int> mockTimestamps = [];

    if (_selectedDays == 1) {
      for (int i = 23; i >= 0; i--) {
        final timestamp =
            now.subtract(Duration(hours: i)).millisecondsSinceEpoch ~/ 1000;
        mockTimestamps.add(timestamp);
      }
    } else {
      for (int i = _selectedDays - 1; i >= 0; i--) {
        final timestamp =
            now.subtract(Duration(days: i)).millisecondsSinceEpoch ~/ 1000;
        mockTimestamps.add(timestamp);
      }
    }

    return mockTimestamps;
  }

  /// Generate realistic mock chart data
  List<double> _generateMockChartData() {
    final currentPrice = quoteData?['c']?.toDouble() ?? 200.0;
    final List<double> mockData = [];

    final symbolHash = widget.symbol.hashCode.abs();
    final startMultiplier = 0.85 + (symbolHash % 20) * 0.01;
    final volatility = 0.02 + (symbolHash % 10) * 0.005;
    final trendDirection = (symbolHash % 3) - 1;

    double price = currentPrice * startMultiplier;
    final dataPoints = _selectedDays == 1 ? 24 : _selectedDays;

    for (int i = 0; i < dataPoints; i++) {
      final trendComponent = trendDirection * (currentPrice * 0.001);
      final randomSeed = (symbolHash + i) % 100;
      final randomVariation =
          (randomSeed - 50) * (currentPrice * volatility) / 50;
      final cyclical = math.sin(i * 0.3) * (currentPrice * 0.01);

      price += trendComponent + randomVariation + cyclical;

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

  /// Get chart color for mock data
  Color _getMockChartColor() {
    final mockData = _generateMockChartData();
    if (mockData.isEmpty) return Colors.white70;

    final firstPrice = mockData.first;
    final lastPrice = mockData.last;

    if (lastPrice > firstPrice) {
      return Colors.green[400]!;
    } else if (lastPrice < firstPrice) {
      return Colors.red[400]!;
    } else {
      return Colors.white70;
    }
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

    if (result == true) {
      setState(() {});
    }
  }

  /// Handle sell stock action
  void _handleSellStock() async {
    final currentPrice = quoteData?['c']?.toDouble() ?? 0.0;

    if (currentPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to sell stock: Price data not available'),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SellStockScreen(
        symbol: widget.symbol,
        currentPrice: currentPrice,
        companyName: profileData?['name'],
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  /// Launch company website safely
  Future<void> _launchCompanyWebsite() async {
    final String? url = profileData?['weburl'];

    if (url != null && url.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(url);

        // Try to launch with platformDefault mode first (more compatible)
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        // If launch fails, show user-friendly message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Website: $url\n(Browser not available on emulator)',
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
        print('Error launching URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.getBG(brightness),
        appBar: _buildAppBar(brightness),
        body: Column(
          children: [
            // TabBarView with Overview and News tabs
            Expanded(
              child: TabBarView(
                children: [
                  // Overview Tab - existing content
                  StockOverviewTab(
                    symbol: widget.symbol,
                    isLoading: isLoading,
                    quoteData: quoteData,
                    profileData: profileData,
                    financialData: financialData,
                    chartDataPoints: chartDataPoints,
                    chartTimestamps: chartTimestamps,
                    chartColor: chartColor,
                    isChartLoading: isChartLoading,
                    selectedDays: _selectedDays,
                    isProfileExpanded: _isProfileExpanded,
                    onDaysChanged: (days) {
                      setState(() {
                        _selectedDays = days;
                      });
                      _updateChart(days);
                    },
                    onProfileToggle: () {
                      setState(() {
                        _isProfileExpanded = !_isProfileExpanded;
                      });
                    },
                    onWebsiteLaunch: _launchCompanyWebsite,
                    sessionManager: _sessionManager,
                  ),
                  // News Tab - new widget
                  StockNewsList(symbol: widget.symbol),
                ],
              ),
            ),
            // Trading buttons at bottom (shown on both tabs)
            _buildTradingButtons(brightness),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// App bar with TabBar
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.getText(brightness)),
        onPressed: () => Navigator.pop(context),
      ),
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
            color: _isInWatchlist
                ? AppColors.getText(brightness)
                : AppColors.getText(brightness),
          ),
        ),
      ],
      // Add TabBar to the bottom of AppBar
      bottom: TabBar(
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'News'),
        ],
        labelColor: AppColors.getText(brightness),
        unselectedLabelColor: AppColors.getText(brightness).withOpacity(0.6),
        indicatorColor: Colors.blue,
      ),
    );
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
}

/// Stock Overview Tab - Contains all the existing overview content
/// Following Lectures.md principles: "keep it simple" and clean separation
class StockOverviewTab extends StatelessWidget {
  final String symbol;
  final bool isLoading;
  final Map<String, dynamic>? quoteData;
  final Map<String, dynamic>? profileData;
  final Map<String, dynamic>? financialData;
  final List<double>? chartDataPoints;
  final List<int>? chartTimestamps;
  final Color chartColor;
  final bool isChartLoading;
  final int selectedDays;
  final bool isProfileExpanded;
  final Function(int) onDaysChanged;
  final VoidCallback onProfileToggle;
  final VoidCallback onWebsiteLaunch;
  final SessionManager sessionManager;

  const StockOverviewTab({
    Key? key,
    required this.symbol,
    required this.isLoading,
    required this.quoteData,
    required this.profileData,
    required this.financialData,
    required this.chartDataPoints,
    required this.chartTimestamps,
    required this.chartColor,
    required this.isChartLoading,
    required this.selectedDays,
    required this.isProfileExpanded,
    required this.onDaysChanged,
    required this.onProfileToggle,
    required this.onWebsiteLaunch,
    required this.sessionManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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

  /// Helper method to safely find user's stock
  PortfolioStock? _findUserStock() {
    final portfolio = sessionManager.getPortfolio();
    try {
      return portfolio.firstWhere(
        (stock) => stock.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Price Chart section
  Widget _buildPriceChart(Brightness brightness) {
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
          // Interactive time period buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildTimeRangeButtons(brightness),
          ),
          SizedBox(height: 16),
          // Chart
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
    final userStock = _findUserStock();
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
            Expanded(
              child: _buildStatCard(
                'Shares',
                userStock?.quantity.toStringAsFixed(0) ?? '0',
                brightness,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Day range',
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
    final previousClose = quoteData?['pc']?.toDouble() ?? 0.0;
    final userStock = _findUserStock();

    double totalReturns = 0.0;
    if (userStock != null && quoteData != null) {
      final currentPrice = quoteData!['c']?.toDouble() ?? 0.0;
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
            Expanded(
              child: _buildStatCard(
                'Previous close',
                '\$${previousClose.toStringAsFixed(2)}',
                brightness,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total returns',
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
    final marketCap = profileData?['marketCapitalization']?.toDouble() ?? 0.0;
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
            Expanded(
              child: _buildStatCard(
                'Market cap',
                _formatMarketCap(marketCap),
                brightness,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Price-Earnings ratio',
                peRatio > 0 ? peRatio.toStringAsFixed(2) : 'N/A',
                brightness,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Company Profile section
  Widget _buildCompanyProfile(Brightness brightness) {
    final industry = profileData?['finnhubIndustry'] ?? 'N/A';
    final country = profileData?['country'] ?? 'N/A';
    final exchange = profileData?['exchange'] ?? 'N/A';
    final websiteUrl = profileData?['weburl'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        SizedBox(height: 16),
        // Show website button if URL is available
        if (websiteUrl != null && websiteUrl.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: onWebsiteLaunch,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                side: BorderSide(
                  color: AppColors.getText(brightness).withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.open_in_new,
                size: 18,
                color: AppColors.getText(brightness),
              ),
              label: Text(
                'Visit Company Website',
                style: TextStyle(
                  color: AppColors.getText(brightness),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          // Show fallback text if no website URL
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Text(
              'Company website not available in the free tier of our data provider.',
              style: TextStyle(
                color: AppColors.getText(brightness).withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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

  /// Format market cap to be readable
  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(2)}T';
    } else if (marketCap >= 1000) {
      return '\$${(marketCap / 1000).toStringAsFixed(2)}B';
    } else {
      return '\$${marketCap.toStringAsFixed(2)}M';
    }
  }

  /// Build interactive time range buttons
  List<Widget> _buildTimeRangeButtons(Brightness brightness) {
    final buttonData = [
      {'label': '1D', 'days': 1},
      {'label': '1W', 'days': 7},
      {'label': '1M', 'days': 30},
      {'label': '3M', 'days': 90},
      {'label': '1Y', 'days': 365},
      {'label': 'ALL', 'days': 1095},
    ];

    return buttonData.map((button) {
      final label = button['label'] as String;
      final days = button['days'] as int;
      final isSelected = selectedDays == days;

      return Padding(
        padding: EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => onDaysChanged(days),
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
}

/// Stock News List Widget - Simple news display for stock
/// Following Lectures.md principles: "keep it simple" and clean implementation
class StockNewsList extends StatefulWidget {
  final String symbol;

  const StockNewsList({Key? key, required this.symbol}) : super(key: key);

  @override
  _StockNewsListState createState() => _StockNewsListState();
}

class _StockNewsListState extends State<StockNewsList> {
  List<NewsArticle> _newsArticles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCompanyNews();
  }

  /// Fetch company news using FinnhubService
  Future<void> _fetchCompanyNews() async {
    try {
      print('Fetching news for ${widget.symbol}...');

      final newsData = await FinnhubService.getCompanyNews(widget.symbol);

      if (newsData != null && newsData.isNotEmpty) {
        final articles = newsData
            .where(
              (item) => _isValidNewsArticle(item),
            ) // Filter out non-news items
            .map<NewsArticle>((item) {
              return NewsArticle(
                id:
                    item['id']?.toString() ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: item['headline'] ?? 'No title',
                content:
                    item['summary'] ??
                    item['headline'] ??
                    'No content available',
                source: item['source'] ?? 'Unknown',
                date: DateTime.fromMillisecondsSinceEpoch(
                  (item['datetime'] ?? 0) * 1000,
                ),
              );
            })
            .toList();

        setState(() {
          _newsArticles = articles
              .take(10)
              .toList(); // Limit to 10 news articles
          _isLoading = false;
        });

        print(
          'Successfully loaded ${_newsArticles.length} news articles (limited to 10)',
        );
      } else {
        setState(() {
          _newsArticles = [];
          _isLoading = false;
        });
        print('No news articles found for ${widget.symbol}');
      }
    } catch (e) {
      print('Error fetching news for ${widget.symbol}: $e');
      setState(() {
        _errorMessage = 'Failed to load news';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.getText(brightness).withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchCompanyNews();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.getText(brightness).withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'No news available for ${widget.symbol}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _newsArticles.length,
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        return _buildNewsItem(article, brightness);
      },
    );
  }

  /// Build individual news item - simple ListTile design
  Widget _buildNewsItem(NewsArticle article, Brightness brightness) {
    return Card(
      color: AppColors.getWidgetBG(brightness),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              getLogoForSource(article.source),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: Icon(
                    Icons.article_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        title: Text(
          article.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                article.source,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getText(brightness).withOpacity(0.7),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(
                  color: AppColors.getText(brightness).withOpacity(0.5),
                ),
              ),
              SizedBox(width: 8),
              Text(
                _getTimeAgo(article.date),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getText(brightness).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.getText(brightness).withOpacity(0.5),
        ),
        onTap: () {
          // TODO: Open article in web view or external browser
          print('Tapped on article: ${article.title}');
        },
      ),
    );
  }

  /// Calculate time ago from DateTime
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Filter out non-news items and ticker data
  bool _isValidNewsArticle(Map<String, dynamic> item) {
    final headline = item['headline']?.toString() ?? '';
    final source = item['source']?.toString() ?? '';

    // Filter out empty headlines
    if (headline.isEmpty || headline.length < 10) {
      return false;
    }

    // Filter out items directly from Finnhub (these are usually ticker updates)
    if (source.toLowerCase() == 'finnhub') {
      return false;
    }

    // Filter out headlines that start with exchange/ticker patterns
    final exchangePatterns = [
      'nasdaq:',
      'nyse:',
      'amex:',
      'otc:',
      'tsx:',
      'lse:',
    ];

    for (final pattern in exchangePatterns) {
      if (headline.toLowerCase().startsWith(pattern)) {
        return false;
      }
    }

    // Filter out headlines that are just ticker symbols (all caps, short)
    if (headline.length <= 5 && headline == headline.toUpperCase()) {
      return false;
    }

    // Must have a valid source (not empty or 'unknown')
    if (source.isEmpty || source.toLowerCase() == 'unknown') {
      return false;
    }

    return true;
  }

  /// Get logo asset path for news source
  String getLogoForSource(String source) {
    switch (source.toLowerCase()) {
      case 'bloomberg':
        return 'assets/images/bloomberg.png';
      case 'marketwatch':
        return 'assets/images/marketwatch.png';
      case 'reuters':
        return 'assets/images/reuters.png';
      case 'seekingalpha':
      case 'seeking alpha': // Handle variation
        return 'assets/images/seekingalpha.png';
      case 'yahoo finance':
      case 'yahoo':
        return 'assets/images/yahoofinance.png';
      default:
        // Use profilepic.jpg as the fallback for any unknown source
        return 'assets/images/profilepic.jpg';
    }
  }
}
