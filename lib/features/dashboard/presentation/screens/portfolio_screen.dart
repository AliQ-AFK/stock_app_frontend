import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/payment_service.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/my_stocks_screen.dart';
import 'package:stock_app_frontend/features/premium/presentation/widgets/pro_badge.dart';
import 'package:stock_app_frontend/features/dashboard/presentation/widgets/stock_card.dart';
import 'package:stock_app_frontend/features/dashboard/presentation/widgets/section_header.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:stock_app_frontend/core/models/stock.dart';
import 'package:stock_app_frontend/core/services/stock_data_service.dart';

/// Portfolio Screen - Main portfolio overview UI
///
/// This screen displays the user's portfolio overview exactly matching the Figma design.
/// Following lectures.md principles of simplicity and clean code structure.
/// Uses SessionManager for synchronous data access without FutureBuilder.
class PortfolioScreen extends StatefulWidget {
  final User user;

  const PortfolioScreen({Key? key, required this.user}) : super(key: key);

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final SessionManager _sessionManager = SessionManager();
  bool _isPro = false;
  bool _isLoading = false;
  List<Stock> _portfolioStocks = [];
  List<Stock> _watchlistStocks = [];

  // Hardcoded placeholder values as specified in requirements
  static const double _placeholderStockPrice =
      150.0; // Used for portfolio calculations
  static const String _totalReturn = "+25% Total Return";
  static const String _avgAnnualReturn = "Avg Annual Return: +5.3%";

  @override
  void initState() {
    super.initState();
    _checkProStatus();
    _loadStockData();
  }

  void _checkProStatus() async {
    bool proStatus = await PaymentService.getProStatus(widget.user.userId);
    setState(() {
      _isPro = proStatus;
    });
  }

  /// Load stock data for portfolio and watchlist
  void _loadStockData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get portfolio and watchlist from SessionManager
      final portfolio = _sessionManager.getPortfolio();
      final watchlistSymbols = _sessionManager.getWishlist();

      // Convert portfolio stocks to Stock objects directly
      final portfolioStocks = <Stock>[];
      for (final portfolioStock in portfolio) {
        try {
          // Get current quote to create Stock object
          final quote = await FinnhubService.getQuote(portfolioStock.symbol);
          if (quote != null) {
            portfolioStocks.add(
              Stock(
                stockID: portfolioStock.symbol,
                symbol: portfolioStock.symbol,
                company: portfolioStock.symbol, // Use symbol as fallback
                exchange: 'NASDAQ', // Default exchange
                currentPrice: quote['c']?.toDouble() ?? 0.0,
                previousClose: quote['pc']?.toDouble() ?? 0.0,
                openPrice:
                    quote['o']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                dayHigh:
                    quote['h']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                dayLow: quote['l']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                volume: 1000000.0, // Default volume
                marketCap: 1000000000.0, // Default market cap
              ),
            );
          }
        } catch (e) {
          print('Error loading portfolio stock ${portfolioStock.symbol}: $e');
        }
      }

      // Convert watchlist symbols to Stock objects directly
      final watchlistStocks = <Stock>[];
      for (final symbol in watchlistSymbols) {
        try {
          // Get current quote to create Stock object
          final quote = await FinnhubService.getQuote(symbol);
          if (quote != null) {
            watchlistStocks.add(
              Stock(
                stockID: symbol,
                symbol: symbol,
                company: symbol, // Use symbol as fallback
                exchange: 'NASDAQ', // Default exchange
                currentPrice: quote['c']?.toDouble() ?? 0.0,
                previousClose: quote['pc']?.toDouble() ?? 0.0,
                openPrice:
                    quote['o']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                dayHigh:
                    quote['h']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                dayLow: quote['l']?.toDouble() ?? quote['c']?.toDouble() ?? 0.0,
                volume: 1000000.0, // Default volume
                marketCap: 1000000000.0, // Default market cap
              ),
            );
          }
        } catch (e) {
          print('Error loading watchlist stock $symbol: $e');
        }
      }

      setState(() {
        _portfolioStocks = portfolioStocks;
        _watchlistStocks = watchlistStocks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stock data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: _buildAppBar(brightness),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTotalPortfolioValueCard(brightness),
            const SizedBox(height: 32),
            _buildMyStocksSection(brightness),
            const SizedBox(height: 32),
            _buildMyWatchlistSection(brightness),
            const SizedBox(height: 100), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  /// Build AppBar exactly matching Figma design
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Portfolio title
          Text(
            'Portfolio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.getText(brightness),
            ),
          ),

          const Spacer(),

          // Pro button - only show when user has Pro status
          if (_isPro) ...[ProBanner(text: 'PRO'), const SizedBox(width: 12)],

          // Search container - clickable to navigate to search screen
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockSearchScreen()),
              );
            },
            child: Container(
              width: 155,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: AppColors.getText(brightness).withOpacity(0.7),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Search...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AppColors.getText(brightness).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.search,
                      color: AppColors.getText(brightness).withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notification icon
          IconButton(
            onPressed: () {
              // TODO: Navigate to notification screen
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.getText(brightness),
              size: 28,
            ),
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  /// Build Total Portfolio Value Card matching Figma design
  Widget _buildTotalPortfolioValueCard(Brightness brightness) {
    final portfolio = _sessionManager.getPortfolio();
    final companiesCount = portfolio.length;

    // Note: We'll use FutureBuilder below to get real market value

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getGreyBG(brightness), // Theme-aware background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Portfolio Value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getText(brightness).withOpacity(0.8),
                  ),
                ),
                Text(
                  '$companiesCount Companies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.getText(brightness).withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total value amount - centered and large using real market prices
            FutureBuilder<double>(
              future: _sessionManager.calculateTotalPortfolioValue(),
              builder: (context, snapshot) {
                final totalValue = snapshot.data ?? 0.0;
                return Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getText(brightness),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Real-time profit/loss with dynamic color (same as dashboard)
            FutureBuilder<Map<String, double>>(
              future: _sessionManager.calculatePortfolioProfitLoss(),
              builder: (context, snapshot) {
                final profitLossData =
                    snapshot.data ?? {'amount': 0.0, 'percentage': 0.0};
                final profitLoss = profitLossData['amount'] ?? 0.0;
                final profitLossPercent = profitLossData['percentage'] ?? 0.0;
                final isPositive = profitLoss >= 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}\$${profitLoss.toStringAsFixed(2)} (${profitLossPercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Total return - centered
            Text(
              _totalReturn,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 4),

            // Average annual return - centered
            Text(
              _avgAnnualReturn,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            // Low Risk Portfolio chip - centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Low Risk Portfolio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.getText(brightness).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build My Stocks Section exactly matching Dashboard design
  Widget _buildMyStocksSection(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Section header with View all button
          SectionHeader(
            title: 'My Stocks',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyStocksScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          // Horizontal stocks list with custom empty state
          _buildStocksHorizontalList(_portfolioStocks, 'stocks'),
        ],
      ),
    );
  }

  /// Build empty state for stocks section
  Widget _buildEmptyStocksState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 32,
            color: AppColors.getText(brightness).withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No stocks yet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getText(brightness).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build My Watchlist Section exactly matching Dashboard design
  Widget _buildMyWatchlistSection(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Section header with View all button
          SectionHeader(
            title: 'My Watchlist',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchlistScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          // Horizontal stocks list with custom empty state
          _buildStocksHorizontalList(_watchlistStocks, 'watchlist'),
        ],
      ),
    );
  }

  /// Builds horizontal scrollable list of stock cards with custom empty states
  Widget _buildStocksHorizontalList(List<Stock> stocks, String type) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    if (stocks.isEmpty) {
      return Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'stocks' ? Icons.trending_up : Icons.visibility,
                size: 32,
                color: AppColors.getText(brightness).withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                type == 'stocks' ? 'No stocks yet' : 'No watchlist yet',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getText(brightness).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 150, // Same as trending stocks height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < stocks.length - 1 ? 12 : 0),
            child: StockCard(
              stock: stocks[index],
              // Navigation handled automatically by StockCard
            ),
          );
        },
      ),
    );
  }
}
