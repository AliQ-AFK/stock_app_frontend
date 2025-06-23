import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/models/portfolio.dart';
import 'package:stock_app_frontend/core/models/stock.dart';
import 'package:stock_app_frontend/core/models/news_article.dart';
import 'package:stock_app_frontend/core/services/portfolio_manager_service.dart';
import 'package:stock_app_frontend/core/services/stock_data_service.dart';
import 'package:stock_app_frontend/core/services/news_service.dart';
import 'package:stock_app_frontend/core/services/watchlist_service.dart';
import '../widgets/portfolio_value_card.dart';
import '../widgets/stock_card.dart';
import '../widgets/news_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/section_header.dart';

/// Dashboard screen for the AlphaWave trading application
///
/// This screen displays the main dashboard with portfolio overview,
/// stocks, news, and watchlist sections. It follows the design
/// specifications from the Figma prototype.
class DashboardScreen extends StatefulWidget {
  /// The currently logged-in user
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Portfolio? _portfolio;
  List<Stock> _myStocks = [];
  List<Stock> _trendingStocks = [];
  List<NewsArticle> _latestNews = [];
  List<Stock> _watchlistStocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Loads all dashboard data from services
  Future<void> _loadDashboardData() async {
    try {
      // Load portfolio data
      final portfolio = await PortfolioManagerService.getUserPortfolio(
        widget.user.userID,
      );

      // Load stocks data
      final allStocks = await StockDataService.getAllStocks();

      // Load news data
      final news = await NewsService.getTrendingNews();

      // Load watchlist data
      final watchlist = await WatchlistService.getUserWatchlist(
        widget.user.userID,
      );
      final watchlistStocks = <Stock>[];

      if (watchlist != null) {
        for (var item in watchlist.items) {
          final stock = await StockDataService.getStockByID(item.stockID);
          if (stock != null) {
            watchlistStocks.add(stock);
          }
        }
      }

      // Update portfolio stock references
      PortfolioManagerService.updateStockReferences();

      setState(() {
        _portfolio = portfolio;
        _myStocks =
            portfolio?.holdings
                .map((h) => h.stock)
                .where((s) => s != null)
                .cast<Stock>()
                .toList() ??
            [];
        _trendingStocks = allStocks;
        _latestNews = news;
        _watchlistStocks = watchlistStocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard data: $e')),
      );
    }
  }

  /// Refreshes dashboard data
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
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

                      // Portfolio Value Card
                      if (_portfolio != null)
                        PortfolioValueCard(portfolio: _portfolio!),

                      const SizedBox(height: 32),

                      // My Stocks Section
                      SectionHeader(
                        title: 'My Stocks',
                        onViewAllPressed: () {
                          // TODO: Navigate to full stocks view
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildHorizontalStocksList(_myStocks),

                      const SizedBox(height: 32),

                      // Latest News Section
                      SectionHeader(
                        title: 'Latest News',
                        onSeeMorePressed: () {
                          // TODO: Navigate to news screen
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNewsSection(),

                      const SizedBox(height: 32),

                      // My Watchlist Section
                      SectionHeader(
                        title: 'My Watchlist',
                        onViewAllPressed: () {
                          // TODO: Navigate to watchlist screen
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildHorizontalStocksList(_watchlistStocks),

                      const SizedBox(height: 32),

                      // Trending Stocks Section
                      SectionHeader(
                        title: 'Trending stocks',
                        showViewAll: false,
                      ),
                      const SizedBox(height: 16),
                      _buildHorizontalStocksList(_trendingStocks),

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

  /// Builds horizontal scrollable list of stock cards
  Widget _buildHorizontalStocksList(List<Stock> stocks) {
    if (stocks.isEmpty) {
      return Container(
        height: 120,
        child: Center(
          child: Text(
            'No stocks available',
            style: TextStyle(
              color: AppColors.getText(
                MediaQuery.of(context).platformBrightness,
              ).withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
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

  /// Builds the news section with vertical list of news cards
  Widget _buildNewsSection() {
    if (_latestNews.isEmpty) {
      return Container(
        height: 120,
        child: Center(
          child: Text(
            'No news available',
            style: TextStyle(
              color: AppColors.getText(
                MediaQuery.of(context).platformBrightness,
              ).withOpacity(0.6),
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
          child: NewsCard(
            article: article,
            onTap: () {
              // TODO: Navigate to news details
            },
          ),
        );
      }).toList(),
    );
  }
}
