import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

/// Simple class to hold combined stock news data
class StockNewsItem {
  final String symbol;
  final String logoUrl;
  final String headline;
  final String source;
  final int datetime;

  StockNewsItem({
    required this.symbol,
    required this.logoUrl,
    required this.headline,
    required this.source,
    required this.datetime,
  });
}

/// News Screen - Maximum Simplicity Approach
///
/// Shows trending stocks carousel and news with company logos
/// instead of article thumbnails for easier implementation
class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  /// Hardcoded list of popular stock symbols for simplicity
  final List<String> popularSymbols = ['AAPL', 'TSLA', 'NVDA', 'AMD', 'META'];

  // State variables
  List<Map<String, dynamic>> trendingStocks = [];
  List<StockNewsItem> stockNews = [];
  bool isLoadingTrending = true;
  bool isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _fetchTrendingData();
    _fetchNewsData();
  }

  /// Fetch trending stocks data (Part 1: Trending Stocks Carousel)
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
        trendingStocks = results;
        isLoadingTrending = false;
      });
    } catch (e) {
      print('Error in _fetchTrendingData: $e');
      setState(() {
        isLoadingTrending = false;
      });
    }
  }

  /// Fetch news data with company logos (Part 2: News List)
  Future<void> _fetchNewsData() async {
    try {
      List<StockNewsItem> newsItems = [];

      for (String symbol in popularSymbols) {
        try {
          // Fetch both company news and profile simultaneously
          final results = await Future.wait([
            FinnhubService.getCompanyNews(symbol),
            FinnhubService.getCompanyProfile(symbol),
          ]);

          final news = results[0] as List<dynamic>;
          final profile = results[1] as Map<String, dynamic>?;

          if (news.isNotEmpty) {
            // Take only the first (most recent) article
            final firstArticle = news[0];
            final logoUrl = profile?['logo'] ?? '';

            newsItems.add(
              StockNewsItem(
                symbol: symbol,
                logoUrl: logoUrl,
                headline: firstArticle['headline'] ?? 'No headline available',
                source: firstArticle['source'] ?? 'Unknown source',
                datetime: firstArticle['datetime'] ?? 0,
              ),
            );
          }
        } catch (e) {
          print('Error fetching news for $symbol: $e');
          // Add fallback news item
          newsItems.add(
            StockNewsItem(
              symbol: symbol,
              logoUrl: '',
              headline: 'Latest updates on $symbol',
              source: 'Market News',
              datetime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            ),
          );
        }
      }

      setState(() {
        stockNews = newsItems;
        isLoadingNews = false;
      });
    } catch (e) {
      print('Error in _fetchNewsData: $e');
      setState(() {
        isLoadingNews = false;
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchTrendingData(), _fetchNewsData()]);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trending Stocks Section
              _buildSectionTitle('Trending Stocks', brightness),
              const SizedBox(height: 16),
              _buildTrendingStocksCarousel(brightness),

              const SizedBox(height: 32),

              // News Section
              _buildSectionTitle('Latest Stock News', brightness),
              const SizedBox(height: 16),
              _buildNewsList(brightness),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar with search functionality
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'News',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.getText(brightness),
            ),
          ),
          const Spacer(),
          // Search container
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
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.getText(brightness),
        ),
      ),
    );
  }

  /// Build trending stocks horizontal carousel
  Widget _buildTrendingStocksCarousel(Brightness brightness) {
    if (isLoadingTrending) {
      return Container(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (trendingStocks.isEmpty) {
      return Container(
        height: 120,
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
      height: 150, // Increased height to prevent overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: trendingStocks.length,
        itemBuilder: (context, index) {
          final stock = trendingStocks[index];
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
                right: index < trendingStocks.length - 1 ? 12 : 0,
              ),
              padding: EdgeInsets.all(12), // Reduced padding
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
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center everything
                mainAxisSize: MainAxisSize.min, // Prevent overflow
                children: [
                  // Company logo - matching My Stocks/Watchlist style
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStockColor(stock['symbol']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: _getStockIcon(stock['symbol'])),
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced spacing
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
                  const SizedBox(height: 2), // Reduced spacing
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
                  const SizedBox(height: 2), // Reduced spacing
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

  /// Build news list with company logos
  Widget _buildNewsList(Brightness brightness) {
    if (isLoadingNews) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (stockNews.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'No news available',
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: stockNews.length,
      itemBuilder: (context, index) {
        final newsItem = stockNews[index];
        return _buildNewsCard(newsItem, brightness);
      },
    );
  }

  /// Build individual news card with company logo
  Widget _buildNewsCard(StockNewsItem newsItem, Brightness brightness) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Company logo (with fallback)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStockColor(newsItem.symbol),
              borderRadius: BorderRadius.circular(8),
            ),
            child: newsItem.logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      newsItem.logoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: _getStockIcon(newsItem.symbol));
                      },
                    ),
                  )
                : Center(child: _getStockIcon(newsItem.symbol)),
          ),

          const SizedBox(width: 16),

          // News content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source and time
                Row(
                  children: [
                    Text(
                      newsItem.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(newsItem.datetime),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // News headline
                Text(
                  newsItem.headline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getText(brightness),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Stock symbol
                Text(
                  newsItem.symbol,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStockColor(newsItem.symbol),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate time ago from timestamp
  String _getTimeAgo(int timestamp) {
    if (timestamp == 0) return 'Recently';

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
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
