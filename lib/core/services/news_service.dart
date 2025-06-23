import '../models/news_article.dart';

/// Manages news articles
///
/// This service provides news management functionality with static
/// mock data for educational purposes.
class NewsService {
  /// Static mock news data
  static final List<NewsArticle> _articles = [
    NewsArticle(
      id: "1",
      title: "Apple Reports Record Quarterly Earnings",
      content:
          "Apple Inc. announced record-breaking quarterly earnings driven by strong iPhone sales and services revenue growth...",
      date: DateTime.now().subtract(Duration(hours: 2)),
      source: "Financial Times",
      trendingTags: ["AAPL", "earnings", "iPhone"],
    ),
    NewsArticle(
      id: "2",
      title: "Tesla Expands Supercharger Network Globally",
      content:
          "Tesla continues its rapid expansion of Supercharger stations worldwide, making electric vehicle adoption more convenient...",
      date: DateTime.now().subtract(Duration(hours: 5)),
      source: "Reuters",
      trendingTags: ["TSLA", "electric vehicles", "infrastructure"],
    ),
    NewsArticle(
      id: "3",
      title: "Microsoft Azure Cloud Services See Strong Growth",
      content:
          "Microsoft's cloud computing division continues to show impressive growth as businesses accelerate digital transformation...",
      date: DateTime.now().subtract(Duration(hours: 8)),
      source: "Bloomberg",
      trendingTags: ["MSFT", "cloud", "enterprise"],
    ),
    NewsArticle(
      id: "4",
      title: "Amazon Prime Day Breaks Sales Records",
      content:
          "Amazon's annual Prime Day event generated record sales across multiple categories, highlighting the strength of e-commerce...",
      date: DateTime.now().subtract(Duration(days: 1)),
      source: "CNBC",
      trendingTags: ["AMZN", "e-commerce", "retail"],
    ),
    NewsArticle(
      id: "5",
      title: "Alphabet Invests Heavily in AI Research",
      content:
          "Google's parent company Alphabet announces significant investments in artificial intelligence research and development...",
      date: DateTime.now().subtract(Duration(days: 2)),
      source: "TechCrunch",
      trendingTags: ["GOOGL", "AI", "research"],
    ),
  ];

  /// Retrieves all news articles
  ///
  /// Returns a list of all news articles sorted by date (newest first)
  static Future<List<NewsArticle>> getAllNews() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_articles)..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retrieves trending news articles
  ///
  /// Returns the most recent news articles (last 24 hours)
  static Future<List<NewsArticle>> getTrendingNews() async {
    await Future.delayed(Duration(milliseconds: 300));
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return _articles
        .where((article) => article.date.isAfter(yesterday))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Searches for news articles by query
  ///
  /// [query] - Search query to match against title, content, or tags
  /// Returns a list of matching news articles
  static Future<List<NewsArticle>> searchNews(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _articles
        .where(
          (article) =>
              article.title.toLowerCase().contains(lowercaseQuery) ||
              article.content.toLowerCase().contains(lowercaseQuery) ||
              article.trendingTags.any(
                (tag) => tag.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retrieves a news article by ID
  ///
  /// [id] - ID of the news article to retrieve
  /// Returns the news article if found, null otherwise
  static Future<NewsArticle?> getNewsById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }
}
