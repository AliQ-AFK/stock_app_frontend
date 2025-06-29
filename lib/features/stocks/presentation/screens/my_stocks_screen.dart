import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';

/// My Stocks Screen - Database-driven portfolio display
/// Following lectures.md requirement: "Portfolio Management Features"
/// Shows real user holdings from database with live pricing
class MyStocksScreen extends StatefulWidget {
  @override
  _MyStocksScreenState createState() => _MyStocksScreenState();
}

class _MyStocksScreenState extends State<MyStocksScreen> {
  // Core state following lectures.md "core features first"
  List<PortfolioStock> _portfolioStocks = [];
  Map<String, double> _currentPrices = {};
  Map<String, Map<String, dynamic>> _stockData =
      {}; // Store quote and profile data
  bool _isLoading = true;

  String _errorMessage = '';

  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  /// Load user's portfolio from session manager and fetch current prices
  /// Following lectures.md performance criteria: "API Response Time: Under 500ms"
  Future<void> _loadPortfolioData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Loading user portfolio from session...');

      // Get portfolio from session manager (synchronous operation)
      final portfolioStocks = _sessionManager.getPortfolio();

      if (portfolioStocks.isEmpty) {
        setState(() {
          _portfolioStocks = [];
          _isLoading = false;
        });
        print('Portfolio is empty');
        return;
      }

      // Fetch current data for all symbols (quotes and company profiles)
      Map<String, Map<String, dynamic>> stockData = {};
      Map<String, double> currentPrices = {};

      for (final stock in portfolioStocks) {
        try {
          // Get quote and basic company profile
          final quote = await FinnhubService.getQuote(stock.symbol);
          final profile = await FinnhubService.getCompanyProfile(stock.symbol);

          stockData[stock.symbol] = {'quote': quote, 'profile': profile};

          if (quote != null && quote['c'] != null) {
            currentPrices[stock.symbol] = quote['c'].toDouble();
          }
        } catch (e) {
          print('Error fetching data for ${stock.symbol}: $e');
        }
      }

      setState(() {
        _portfolioStocks = portfolioStocks;
        _currentPrices = currentPrices;
        _stockData = stockData;
        _isLoading = false;
      });

      print('Portfolio loaded: ${_portfolioStocks.length} stocks');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading portfolio: ${e.toString()}';
      });
      print('Error loading portfolio: $e');
    }
  }

  /// Calculate profit/loss for a stock
  double _calculateProfitLoss(PortfolioStock stock) {
    final currentPrice = _currentPrices[stock.symbol] ?? 0.0;
    return stock.getProfitLoss(currentPrice);
  }

  /// Calculate profit/loss percentage for a stock
  double _calculateProfitLossPercent(PortfolioStock stock) {
    final currentPrice = _currentPrices[stock.symbol] ?? 0.0;
    return stock.getProfitLossPercentage(currentPrice);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: _buildAppBar(brightness),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget(brightness)
          : _portfolioStocks.isEmpty
          ? _buildEmptyState(brightness)
          : _buildPortfolioContent(brightness),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.getText(brightness),
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My stocks',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.getText(brightness),
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.getText(brightness).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPortfolioData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: AppColors.getText(brightness).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Your portfolio is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.getText(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start investing by searching for stocks',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockSearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Search Stocks'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main portfolio content
  Widget _buildPortfolioContent(Brightness brightness) {
    return Column(
      children: [
        // Header section with company count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 16),
          child: Row(
            children: [
              Text(
                '${_portfolioStocks.length} Companies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getText(brightness),
                ),
              ),
            ],
          ),
        ),

        // Portfolio holdings list - big slider design
        Container(
          height: 150, // Same height as trending stocks
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _portfolioStocks.length,
            itemBuilder: (context, index) {
              final stock = _portfolioStocks[index];
              return _buildBigPortfolioCard(stock, brightness, index);
            },
          ),
        ),
      ],
    );
  }

  /// Build big portfolio card matching trending stocks design
  Widget _buildBigPortfolioCard(
    PortfolioStock stock,
    Brightness brightness,
    int index,
  ) {
    final currentPrice = _currentPrices[stock.symbol] ?? 0.0;
    final profitLossPercent = _calculateProfitLossPercent(stock);
    final isPositive = profitLossPercent >= 0;
    final totalValue = currentPrice * stock.quantity;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailScreen(symbol: stock.symbol),
          ),
        );
      },
      child: Container(
        width: 140, // Same width as trending stocks
        margin: EdgeInsets.only(left: index == 0 ? 10 : 6, right: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getGreyBG(brightness),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Company logo (centered at top)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStockColor(stock.symbol),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _getStockIcon(stock.symbol)),
            ),
            const SizedBox(height: 8),

            // Symbol (centered)
            Text(
              stock.symbol,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Current price (centered)
            Text(
              currentPrice > 0 ? '\$${currentPrice.toStringAsFixed(2)}' : 'N/A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Percentage change (centered)
            Text(
              '${isPositive ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPositive
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the brand color for different stocks
  Color _getStockColor(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Color(0xFFE31937); // Tesla red
      case 'AAPL':
        return Color(0xFF000000); // Apple black
      case 'NVDA':
        return Color(0xFF76B900); // NVIDIA green
      case 'AMD':
        return Color(0xFFED1C24); // AMD red
      case 'META':
        return Color(0xFF0866FF); // Meta blue
      case 'GOOGL':
        return Color(0xFF4285F4); // Google blue
      case 'MSFT':
        return Color(0xFF00BCF2); // Microsoft blue
      case 'AMZN':
        return Color(0xFFFF9900); // Amazon orange
      default:
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.pink,
        ];
        return colors[symbol.hashCode % colors.length];
    }
  }

  /// Gets the appropriate icon for different stocks
  Widget _getStockIcon(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            'T',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'System',
            ),
          ),
        );
      case 'AAPL':
        return Container(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.apple, color: Colors.white, size: 28),
        );
      case 'NVDA':
        return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            'N',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 'AMD':
        return Container(
          padding: EdgeInsets.all(6),
          child: Text(
            'AMD',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      case 'META':
        return Container(
          padding: EdgeInsets.all(8),
          child: Transform.rotate(
            angle: 0.1,
            child: Text(
              'f',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'GOOGL':
        return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      case 'MSFT':
        return Container(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.window, color: Colors.white, size: 26),
        );
      case 'AMZN':
        return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            'a',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            symbol.substring(0, 1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
    }
  }
}
