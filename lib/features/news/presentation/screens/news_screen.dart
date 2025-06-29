import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/core/services/payment_service.dart';
import 'package:stock_app_frontend/features/premium/presentation/widgets/pro_badge.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

/// Hard-coded news item for the news section
class HardCodedNewsItem {
  final String title;
  final String source;
  final String timeAgo;
  final String? badge; // "Top Story", "Sponsored", etc.
  final Color backgroundColor;
  final String imagePath;

  HardCodedNewsItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    this.badge,
    required this.backgroundColor,
    required this.imagePath,
  });
}

/// News Screen - Following Figma Design
///
/// Keeps trending stocks real, but uses hard-coded news data
/// matching the exact Figma prototype design
class NewsScreen extends StatefulWidget {
  final User user;

  const NewsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  /// Hardcoded list of popular stock symbols for trending stocks
  final List<String> popularSymbols = ['TSLA', 'AAPL', 'NVDA', 'AMD', 'META'];

  // State variables for trending stocks (keeping this real)
  List<Map<String, dynamic>> trendingStocks = [];
  bool isLoadingTrending = true;

  // Hard-coded news data matching Figma design
  late List<HardCodedNewsItem> hardCodedNews;

  // PRO status variables
  bool _isPro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
    _fetchTrendingData();
  }

  void _checkProStatus() async {
    bool proStatus = await PaymentService.getProStatus(widget.user.userId);
    setState(() {
      _isPro = proStatus;
      _isLoading = false;
    });
  }

  /// Initialize hard-coded news data matching Figma design
  void _initializeHardCodedNews(Brightness brightness) {
    hardCodedNews = [
      HardCodedNewsItem(
        title: 'Federal Reserve Signals Rate Changes',
        source: 'Bloomberg',
        timeAgo: '2h ago',
        badge: 'Top Story',
        backgroundColor: AppColors.getGreyBG(brightness),
        imagePath: 'assets/images/bloomberg.png',
      ),
      HardCodedNewsItem(
        title: 'Tech Sector Leads Market Rally',
        source: 'Reuters',
        timeAgo: '4h ago',
        backgroundColor: AppColors.getGreyBG(brightness),
        imagePath: 'assets/images/reuters.png',
      ),
      HardCodedNewsItem(
        title: 'Investment Strategies for Market Volatility',
        source: 'MarketWatch',
        timeAgo: '5h ago',
        badge: 'Sponsored',
        backgroundColor: AppColors.getWidgetBG(brightness),
        imagePath: 'assets/images/marketwatch.png',
      ),
      HardCodedNewsItem(
        title: 'Global Markets React to Asian Trading Updates',
        source: 'Yahoo Mail',
        timeAgo: '6h ago',
        backgroundColor: AppColors.getGreyBG(brightness),
        imagePath: 'assets/images/yahoofinance.png', // Yahoo Mail logo
      ),
    ];
  }

  /// Fetch trending stocks data (keeping this real as requested)
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    // Initialize hard-coded news with theme colors
    _initializeHardCodedNews(brightness);

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: _buildAppBar(brightness),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchTrendingData();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trending Stocks Section (keeping same)
              _buildSectionTitle('Trending Stocks', brightness),
              const SizedBox(height: 16),
              _buildTrendingStocksCarousel(brightness),

              const SizedBox(height: 32),

              // News Section (hard-coded matching Figma)
              _buildSectionTitle('News', brightness),
              const SizedBox(height: 16),
              _buildHardCodedNewsList(brightness),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar matching Figma design
  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.getBG(brightness),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'Latest News',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.getText(brightness),
            ),
          ),
          // PRO badge - only show when user has Pro status
          if (_isPro) ...[const SizedBox(width: 8), ProBanner(text: 'PRO')],
          const Spacer(),
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
              size: 24,
            ),
            padding: EdgeInsets.zero,
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
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.getText(brightness),
        ),
      ),
    );
  }

  /// Build trending stocks horizontal carousel (keeping same)
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
      height: 150,
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
                  // Company logo
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
                  const SizedBox(height: 8),
                  // Symbol
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
                  // Price
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
                  // Change percentage
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

  /// Build hard-coded news list matching Figma design
  Widget _buildHardCodedNewsList(Brightness brightness) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: hardCodedNews.length,
      itemBuilder: (context, index) {
        final newsItem = hardCodedNews[index];
        return _buildHardCodedNewsCard(newsItem, brightness);
      },
    );
  }

  /// Build individual news card matching Figma design
  Widget _buildHardCodedNewsCard(
    HardCodedNewsItem newsItem,
    Brightness brightness,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: newsItem.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // News image/illustration
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                newsItem.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[600],
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

          const SizedBox(width: 16),

          // News content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source, time, and badge row
                Row(
                  children: [
                    Text(
                      newsItem.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.getText(brightness).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      newsItem.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getText(brightness).withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    // Badge if present
                    if (newsItem.badge != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: newsItem.badge == 'Top Story'
                              ? Colors.orange
                              : Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          newsItem.badge!,
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

                // News title
                Text(
                  newsItem.title,
                  style: TextStyle(
                    fontSize: 16,
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

          const SizedBox(width: 8),

          // Arrow icon
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.getText(brightness).withOpacity(0.6),
            size: 16,
          ),
        ],
      ),
    );
  }

  /// Get brand color for different stocks (keeping same)
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

  /// Get appropriate icon for different stocks (keeping same)
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
