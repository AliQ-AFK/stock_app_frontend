/// Represents a news article
///
/// This class stores news article information for the news feed
/// feature of the AlphaWave application.
class NewsArticle {
  /// Unique identifier for the news article
  String id;

  /// Title of the news article
  String title;

  /// Content/body of the news article
  String content;

  /// Publication date of the article
  DateTime date;

  /// Source of the news article
  String source;

  /// List of trending tags associated with the article
  List<String> trendingTags;

  /// Creates a new NewsArticle instance
  ///
  /// [id] - Unique identifier for the news article
  /// [title] - Title of the news article
  /// [content] - Content/body of the news article
  /// [date] - Publication date of the article
  /// [source] - Source of the news article
  /// [trendingTags] - Optional list of trending tags, defaults to empty list
  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.source,
    List<String>? trendingTags,
  }) : trendingTags = trendingTags ?? [];
}
