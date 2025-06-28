import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/models/stock.dart';
import 'package:stock_app_frontend/core/models/news_article.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/stock_data_service.dart';
import 'package:stock_app_frontend/core/services/news_service.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/my_stocks_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';
import '../widgets/stock_card.dart';
import '../widgets/news_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/section_header.dart';

/// Dashboard screen for the AlphaWave trading application
///
/// Following Lectures.md requirements: "Dashboard: A comprehensive overview
/// of the user's portfolio and market trends"
/// Uses SessionManager for simplified state management
class DashboardScreen extends StatefulWidget {
  /// The currently logged-in user
  final User user;

  /// Callback to navigate to news tab
  final VoidCallback? onNavigateToNews;

  const DashboardScreen({Key? key, required this.user, this.onNavigateToNews})
    : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SessionManager _sessionManager = SessionManager();
  List<Stock> _myStocks = [];
  List<Stock> _trendingStocks = [];
  List<NewsArticle> _latestNews = [];
  List<Stock> _watchlistStocks = [];
  bool _isLoading = true;

  // New trending stocks state
  final List<String> popularSymbols = ['AAPL', 'TSLA', 'NVDA', 'AMD', 'META'];
  List<Map<String, dynamic>> newTrendingStocks = [];
  bool isLoadingTrending = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _fetchTrendingData();
  }

  /// Loads all dashboard data using simplified services
  /// Following Lectures.md performance criteria: "Under 500ms for all requests"
  Future<void> _loadDashboardData() async {
    try {
      // Load portfolio data from SessionManager
      final portfolioStocks = _sessionManager.getPortfolio();
      final watchlistSymbols = _sessionManager.getWishlist();

      // Load all stocks data
      final allStocks = await StockDataService.getAllStocks();

      // Load news data from API
      final news = await NewsService.getTrendingNews();
      print('Dashboard: Loaded ${news.length} news articles');

      // Convert portfolio stocks to Stock objects
      final myStocks = <Stock>[];
      for (final portfolioStock in portfolioStocks) {
        final stock = await StockDataService.getStockBySymbol(
          portfolioStock.symbol,
        );
        if (stock != null) {
          myStocks.add(stock);
        }
      }

      // Convert watchlist symbols to Stock objects
      final watchlistStocks = <Stock>[];
      for (final symbol in watchlistSymbols) {
        final stock = await StockDataService.getStockBySymbol(symbol);
        if (stock != null) {
          watchlistStocks.add(stock);
        }
      }

      setState(() {
        _myStocks = myStocks;
        _trendingStocks = allStocks;
        _latestNews = news;
        _watchlistStocks = watchlistStocks;
        _isLoading = false;
      });
    } catch (e) {
      print('Dashboard: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading dashboard data')));
    }
  }

  /// Fetch trending stocks data (same as news screen)
  Future<void> _fetchTrendingData() async {
    try {
      List<Map<String, dynamic>> results = [];

      for (String symbol in popularSymbols) {
        try {
          final quote = await FinnhubService.getQuote(symbol);
          if (quote != null) {
            results.add({
              'symbol': symbol,
              'changePercent': quote['dp']?.toDouble() ?? 0.0,
              'price': quote['c']?.toDouble() ?? 0.0,
            });
          }
        } catch (e) {
          print('Error fetching trending data for $symbol: $e');
          // Add fallback data
          results.add({'symbol': symbol, 'changePercent': 0.0, 'price': 0.0});
        }
      }

      setState(() {
        newTrendingStocks = results;
        isLoadingTrending = false;
      });
    } catch (e) {
      print('Error in _fetchTrendingData: $e');
      setState(() {
        isLoadingTrending = false;
      });
    }
  }

  /// Refreshes dashboard data
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([_loadDashboardData(), _fetchTrendingData()]);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Dashboard title
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),
            const Spacer(),

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
                            color: AppColors.getText(
                              brightness,
                            ).withOpacity(0.5),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
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
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Header
                      DashboardHeader(user: widget.user),

                      const SizedBox(height: 24),

                      // Portfolio Summary Card
                      _buildPortfolioSummaryCard(),

                      const SizedBox(height: 32),

                      // My Stocks Section
                      SectionHeader(
                        title: 'My Stocks',
                        onViewAllPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyStocksScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStocksHorizontalList(_myStocks, 'stocks'),

                      const SizedBox(height: 32),

                      // Latest News Section
                      SectionHeader(
                        title: 'Latest News',
                        onSeeMorePressed: () {
                          // Navigate to news tab using callback
                          if (widget.onNavigateToNews != null) {
                            widget.onNavigateToNews!();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNewsSection(),

                      const SizedBox(height: 32),

                      // My Watchlist Section
                      SectionHeader(
                        title: 'My Watchlist',
                        onViewAllPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WatchlistScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStocksHorizontalList(_watchlistStocks, 'watchlist'),

                      const SizedBox(height: 32),

                      // Trending Stocks Section
                      SectionHeader(
                        title: 'Trending stocks',
                        showViewAll: false,
                      ),
                      const SizedBox(height: 16),
                      _buildNewTrendingStocksCarousel(brightness),

                      const SizedBox(
                        height: 100,
                      ), // Bottom padding for navigation
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Builds portfolio value card matching My Stocks screen design
  /// Following Lectures.md requirement: "Portfolio Summary: A high-level view"
  Widget _buildPortfolioSummaryCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    final portfolioSummary = _sessionManager.getPortfolioSummary();
    final totalCost = portfolioSummary['totalCost'] ?? 0.0;

    // Hardcoded values like in portfolio screen
    const dailyChangeAmount = "+\$0.00";
    const dailyChangePercent = "(0.00%)";

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center, // Center everything
        children: [
          // Portfolio Value title
          Text(
            'Portfolio Value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Total value amount - prominent display
          Text(
            '\$${totalCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 48, // Increased font size for prominence
              fontWeight: FontWeight.bold,
              color: AppColors.getText(brightness),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Daily change with green arrow - centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the row
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '$dailyChangeAmount $dailyChangePercent',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
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
                type == 'stocks'
                    ? Icons.trending_up
                    : type == 'watchlist'
                    ? Icons.visibility
                    : Icons.trending_up,
                size: 32,
                color: AppColors.getText(brightness).withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                type == 'stocks'
                    ? 'No stocks yet'
                    : type == 'watchlist'
                    ? 'No watchlist yet'
                    : 'No stocks available',
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
      height: 150, // Increased to match trending stocks size
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < stocks.length - 1 ? 12 : 0),
            child: StockCard(
              stock: stocks[index],
              onTap: () {
                // TODO: Navigate to stock details
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds the news section with Top Story badges and clean design
  Widget _buildNewsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    if (_latestNews.isEmpty) {
      return Container(
        height: 120,
        child: Center(
          child: Text(
            'No news available',
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _latestNews.take(2).map((article) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTopNewsCard(article, brightness),
        );
      }).toList(),
    );
  }

  /// Build individual news card with Top Story badge matching the design
  Widget _buildTopNewsCard(NewsArticle article, Brightness brightness) {
    final isTopStory = _isTopStory(article);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getGreyBG(brightness), // Theme-aware background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // News icon (grey background with document icon)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.article_outlined, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          // News content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source, time, and Top Story badge
                Row(
                  children: [
                    Text(
                      article.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(article.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    // Top Story badge
                    if (isTopStory)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Top Story',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // News headline
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getText(brightness),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.getText(brightness).withOpacity(0.5),
            size: 16,
          ),
        ],
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

  /// Determines if this article should be marked as a top story
  bool _isTopStory(NewsArticle article) {
    final now = DateTime.now();
    final difference = now.difference(article.date);

    // Mark as top story if published within the last 6 hours
    return difference.inHours <= 6;
  }

  /// Build new trending stocks carousel (same design as news screen)
  Widget _buildNewTrendingStocksCarousel(Brightness brightness) {
    if (isLoadingTrending) {
      return Container(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (newTrendingStocks.isEmpty) {
      return Container(
        height: 150,
        child: Center(
          child: Text(
            'Unable to load trending stocks',
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 150, // Same height as news screen
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: newTrendingStocks.length,
        itemBuilder: (context, index) {
          final stock = newTrendingStocks[index];
          final changePercent = stock['changePercent'] as double;
          final isPositive = changePercent >= 0;
          final price = stock['price'] as double;

          return GestureDetector(
            onTap: () {
              // Navigate to stock detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StockDetailScreen(symbol: stock['symbol']),
                ),
              );
            },
            child: Container(
              width: 140,
              margin: EdgeInsets.only(
                right: index < newTrendingStocks.length - 1 ? 12 : 0,
              ),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getGreyBG(brightness),
                border: Border.all(
                  color: AppColors.getText(brightness).withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Company logo - real company logos
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getGreyBG(brightness),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://logo.clearbit.com/${_getCompanyDomain(stock['symbol'])}.com',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: _getStockColor(stock['symbol']),
                              child: Center(
                                child: _getStockIcon(stock['symbol']),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Symbol - centered
                  Center(
                    child: Text(
                      stock['symbol'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getText(brightness),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Price - centered
                  if (price > 0)
                    Center(
                      child: Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getText(brightness).withOpacity(0.7),
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Change percentage - centered
                  Center(
                    child: Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get company domain for logo fetching
  String _getCompanyDomain(String symbol) {
    switch (symbol) {
      case 'AAPL':
        return 'apple';
      case 'TSLA':
        return 'tesla';
      case 'NVDA':
        return 'nvidia';
      case 'AMD':
        return 'amd';
      case 'META':
        return 'meta';
      case 'GOOGL':
        return 'google';
      case 'MSFT':
        return 'microsoft';
      case 'AMZN':
        return 'amazon';
      default:
        return symbol.toLowerCase();
    }
  }

  /// Get brand color for different stocks
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
      default:
        return Colors.blue;
    }
  }

  /// Get appropriate icon for different stocks
  Widget _getStockIcon(String symbol) {
    switch (symbol) {
      case 'TSLA':
        return Text(
          'T',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'AAPL':
        return Icon(Icons.apple, color: Colors.white, size: 24);
      case 'NVDA':
        return Text(
          'N',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'AMD':
        return Text(
          'AMD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'META':
        return Text(
          'f',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );
      default:
        return Text(
          symbol.substring(0, 1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
    }
  }
}
