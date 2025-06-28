import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';

/// Stock Search Screen implementing the Figma design
///
/// This screen provides real-time stock search functionality with:
/// - Debounced search input (500ms delay)
/// - Integration with Finnhub API
/// - Clean UI matching the provided Figma design
/// - Proper error handling and loading states
class StockSearchScreen extends StatefulWidget {
  @override
  _StockSearchScreenState createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  // State Variables as per requirements
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasText = false;

  // Cache for company logos to avoid repeated API calls
  Map<String, String> _logoCache = {};

  // Rate limiting flag to temporarily disable logo fetching
  bool _isRateLimited = false;

  // FinnhubService provides static methods for API calls

  @override
  void initState() {
    super.initState();
    // Add listener to search controller
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });

    // Debug: Check if API key is configured
    _checkApiConfiguration();
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Debouncing Logic Implementation
  ///
  /// This method implements a 500ms debouncer to prevent excessive API calls
  /// while the user is typing. The API call is only made after the user
  /// has paused typing for 500 milliseconds.
  void _onSearchChanged(String query) {
    // Cancel any existing timer
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Update text state for UI
    setState(() {
      _hasText = query.trim().isNotEmpty;
    });

    // Clear results if query is empty
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    // Set up new timer with 500ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  /// API Call Logic Implementation
  ///
  /// This method handles the actual API call to Finnhub search endpoint.
  /// It properly manages loading states and error handling as required.
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    print('Starting search for: "$query"');

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Call the FinnhubService.searchStocks method
      print('Making API call to Finnhub...');
      final response = await FinnhubService.searchStocks(query);
      print('API response received: ${response.toString()}');

      // Extract the results from the "result" key as specified
      final results = response['result'] as List<dynamic>? ?? [];
      print('Found ${results.length} results');

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors with proper error messaging
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error searching stocks: ${e.toString()}';
        _searchResults = [];
      });

      // Log error for debugging (following best practices)
      print('Stock search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: _buildAppBar(brightness),
      body: Column(
        children: [
          _buildSearchBar(brightness),
          Expanded(child: _buildSearchResults(brightness)),
        ],
      ),
    );
  }

  /// Build AppBar matching Figma design
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
        'Search Stocks',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.getText(brightness),
        ),
      ),
      centerTitle: false,
    );
  }

  /// Build Search Bar exactly matching the Figma design
  ///
  /// This widget implements the search bar with proper styling,
  /// icons, and interaction as shown in the Figma design.
  Widget _buildSearchBar(Brightness brightness) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.getBG(brightness),
        border: Border.all(
          color: AppColors.getText(brightness).withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.getText(brightness),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search stocks by symbol or name...',
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.getText(brightness).withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.getText(brightness).withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.getText(brightness).withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                      _errorMessage = '';
                      _hasText = false;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  /// Build Search Results matching Figma design
  ///
  /// This widget handles all search result states:
  /// - Loading indicator
  /// - Error messages
  /// - Empty results
  /// - Results list with proper Figma styling
  Widget _buildSearchResults(Brightness brightness) {
    // Show loading indicator during API call
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.getText(brightness),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Searching stocks...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getText(brightness).withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Show error message if API call failed
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
                fontSize: 16,
                color: AppColors.getText(brightness).withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performSearch(_searchController.text.trim());
                }
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state when no search has been performed
    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.getText(brightness).withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'Search for stocks',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.getText(brightness).withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter a stock symbol or company name to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getText(brightness).withOpacity(0.4),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show no results message when search returns empty
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.getText(brightness).withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.getText(brightness).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with a different term',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getText(brightness).withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Build the results list with exact Figma styling
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 26),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return _buildStockResultItem(stock, brightness);
      },
    );
  }

  /// Build individual stock result item with company logo
  ///
  /// This widget creates each stock result row with:
  /// - Company logo (with fallback to letter icon)
  /// - Stock symbol in bold/dark text
  /// - Company description in gray text below symbol
  /// - Proper spacing and typography per Figma
  /// - Tap handler as required
  Widget _buildStockResultItem(dynamic stock, Brightness brightness) {
    // Extract stock data from Finnhub API response
    final symbol = stock['symbol']?.toString() ?? '';
    final description = stock['description']?.toString() ?? '';
    final type = stock['type']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Print statement as required in specifications
            print('Selected stock symbol: $symbol');

            // Navigate to stock detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(symbol: symbol),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                // Company logo with fallback to letter icon
                _buildCompanyLogo(symbol, brightness),

                SizedBox(width: 16),

                // Stock information matching Figma layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stock symbol in bold/dark text as per Figma
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getText(brightness),
                        ),
                      ),

                      SizedBox(height: 4),

                      // Company description in gray text as per Figma
                      Text(
                        description.isNotEmpty ? description : type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.getText(brightness).withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow icon indicating tappable item
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.getText(brightness).withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Generate color for stock icon based on symbol
  ///
  /// This method provides consistent colors for stock symbols
  /// to improve visual recognition and match design standards.
  Color _getStockColor(String symbol) {
    // Use deterministic color generation based on symbol
    final colors = [
      Color(0xFF1E88E5), // Blue
      Color(0xFF43A047), // Green
      Color(0xFFE53935), // Red
      Color(0xFFFB8C00), // Orange
      Color(0xFF8E24AA), // Purple
      Color(0xFF00ACC1), // Cyan
      Color(0xFF3949AB), // Indigo
      Color(0xFF8BC34A), // Light Green
    ];

    final hash = symbol.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Build company logo widget with efficient caching
  /// Following Lectures.md "keep it simple" principle
  Widget _buildCompanyLogo(String symbol, Brightness brightness) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.getWidgetBG(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.getText(brightness).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FutureBuilder<String?>(
          future: _fetchCompanyLogo(symbol),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              // Show company logo
              return Image.network(
                snapshot.data!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIcon(symbol);
                },
              );
            } else {
              // Show fallback letter icon while loading or if no logo
              return _buildFallbackIcon(symbol);
            }
          },
        ),
      ),
    );
  }

  /// Build fallback icon with first letter of symbol
  Widget _buildFallbackIcon(String symbol) {
    return Container(
      decoration: BoxDecoration(
        color: _getStockColor(symbol),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Fetch company logo with caching and rate limiting
  /// Only makes API call if logo not already cached and not rate limited
  Future<String?> _fetchCompanyLogo(String symbol) async {
    if (symbol.isEmpty) return null;

    // Check cache first
    if (_logoCache.containsKey(symbol)) {
      return _logoCache[symbol];
    }

    // Skip API call if we're currently rate limited
    if (_isRateLimited) {
      print('Skipping logo fetch for $symbol - rate limited');
      _logoCache[symbol] = '';
      return null;
    }

    try {
      // Add small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 200));

      // Fetch company profile to get logo
      final companyProfile = await FinnhubService.getCompanyProfile(symbol);
      final logoUrl = companyProfile?['logo'] ?? '';

      // Cache the result (even if empty)
      _logoCache[symbol] = logoUrl;

      return logoUrl.isNotEmpty ? logoUrl : null;
    } catch (e) {
      print('Error fetching logo for $symbol: $e');

      // Cache empty result to avoid repeated failed attempts
      _logoCache[symbol] = '';

      // If it's a 403 error, enable rate limiting temporarily
      if (e.toString().contains('403')) {
        print('Rate limit hit - disabling logo fetching for 30 seconds');
        _isRateLimited = true;

        // Re-enable after 30 seconds
        Timer(Duration(seconds: 30), () {
          _isRateLimited = false;
          print('Logo fetching re-enabled');
        });
      }

      return null;
    }
  }

  /// Debug method to check API configuration
  void _checkApiConfiguration() {
    if (FinnhubService.isApiKeyConfigured()) {
      print('API key is configured');
    } else {
      print('API key is NOT configured - please check your .env file');
    }
  }
}
