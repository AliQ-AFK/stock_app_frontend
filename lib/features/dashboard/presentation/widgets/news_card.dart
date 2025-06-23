import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/news_article.dart';

/// News card widget
///
/// Displays news articles in a card format as shown in the Figma design
/// with image, headline, source, and time information.
class NewsCard extends StatelessWidget {
  /// The news article to display
  final NewsArticle article;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const NewsCard({Key? key, required this.article, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isLightMode = brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // News image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _getNewsImage(),
              ),
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
                        article.source,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeAgo(article.date),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      // Top Story badge for recent articles
                      if (_isTopStory())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Gets a placeholder image for the news article
  Widget _getNewsImage() {
    // Return different placeholder images based on article content
    if (article.title.toLowerCase().contains('federal') ||
        article.title.toLowerCase().contains('rate')) {
      return Container(
        color: Colors.blue[800],
        child: const Icon(Icons.account_balance, color: Colors.white, size: 24),
      );
    } else if (article.title.toLowerCase().contains('tech') ||
        article.title.toLowerCase().contains('market')) {
      return Container(
        color: Colors.green[700],
        child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
      );
    } else {
      return Container(
        color: Colors.grey[700],
        child: const Icon(Icons.article, color: Colors.white, size: 24),
      );
    }
  }

  /// Calculates time ago string from the article date
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
  bool _isTopStory() {
    final now = DateTime.now();
    final difference = now.difference(article.date);

    // Mark as top story if published within the last 6 hours
    return difference.inHours <= 6;
  }
}
