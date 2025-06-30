import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/core/services/finnhub_service.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_search_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/stock_detail_screen.dart';

/// Watchlist Screen - Database-driven watchlist display
/// Following lectures.md requirement: "Watchlist: A customizable list of stocks for users to monitor"
/// Shows stocks saved to user's watchlist with live pricing
class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // Core state following lectures.md "core features first"
  List<String> _watchlistSymbols = [];
  Map<String, Map<String, dynamic>> _stockData =
      {}; // Store quote and profile data
  bool _isLoading = true;
  String _errorMessage = '';

  // Simple delete functionality
  bool _isDeleteMode = false;
  Set<String> _selectedForDelete = {};

  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _loadWatchlistData();
  }

  /// Load user's watchlist from session manager and fetch current data
  /// Following lectures.md performance criteria: "API Response Time: Under 500ms"
  Future<void> _loadWatchlistData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Loading user watchlist from session...');

      // Get watchlist from session manager (synchronous operation)
      final watchlistSymbols = _sessionManager.getWishlist();

      if (watchlistSymbols.isEmpty) {
        setState(() {
          _watchlistSymbols = [];
          _isLoading = false;
        });
        print('Watchlist is empty');
        return;
      }

      // Fetch current data for all symbols (quotes and basic profile)
      Map<String, Map<String, dynamic>> stockData = {};

      for (final symbol in watchlistSymbols) {
        try {
          // Get quote and basic company profile
          final quote = await FinnhubService.getQuote(symbol);
          final profile = await FinnhubService.getCompanyProfile(symbol);

          stockData[symbol] = {'quote': quote, 'profile': profile};
        } catch (e) {
          print('Error fetching data for $symbol: $e');
        }
      }

      setState(() {
        _watchlistSymbols = watchlistSymbols;
        _stockData = stockData;
        _isLoading = false;
      });

      print('Watchlist loaded: ${_watchlistSymbols.length} stocks');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading watchlist: ${e.toString()}';
      });
      print('Error loading watchlist: $e');
    }
  }

  /// Toggle delete mode
  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedForDelete.clear();
    });
  }

  /// Delete selected stocks
  void _deleteSelected() {
    try {
      for (final symbol in _selectedForDelete) {
        _sessionManager.removeFromWishlist(symbol);
      }

      setState(() {
        _watchlistSymbols.removeWhere((s) => _selectedForDelete.contains(s));
        for (final symbol in _selectedForDelete) {
          _stockData.remove(symbol);
        }
        _selectedForDelete.clear();
        _isDeleteMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed stocks from watchlist'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing stocks'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove stock from watchlist
  void _removeFromWatchlist(String symbol) {
    try {
      final success = _sessionManager.removeFromWishlist(symbol);
      if (success) {
        setState(() {
          _watchlistSymbols.removeWhere((s) => s == symbol);
          _stockData.remove(symbol);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $symbol from watchlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing $symbol: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          : _watchlistSymbols.isEmpty
          ? _buildEmptyState(brightness)
          : _buildWatchlistContent(brightness),
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
        _isDeleteMode ? 'Select to Delete' : 'My Watchlist',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.getText(brightness),
        ),
      ),
      actions: _watchlistSymbols.isNotEmpty
          ? [
              if (_isDeleteMode && _selectedForDelete.isNotEmpty)
                IconButton(
                  onPressed: _deleteSelected,
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              IconButton(
                onPressed: _toggleDeleteMode,
                icon: Icon(
                  _isDeleteMode ? Icons.close : Icons.edit,
                  color: AppColors.getText(brightness),
                ),
              ),
            ]
          : null,
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
            onPressed: _loadWatchlistData,
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
            Icons.remove_red_eye_outlined,
            size: 64,
            color: AppColors.getText(brightness).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.getText(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add stocks to monitor them here',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockSearchScreen()),
              );
              // Refresh watchlist if a stock was added
              if (result == true) {
                _loadWatchlistData();
              }
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

  /// Build main watchlist content
  Widget _buildWatchlistContent(Brightness brightness) {
    return Column(
      children: [
        // Header section with count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 16),
          child: Row(
            children: [
              Text(
                '${_watchlistSymbols.length} Companies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getText(brightness),
                ),
              ),
            ],
          ),
        ),

        // Watchlist items - big slider design
        Container(
          height: 150, // Same height as trending stocks
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _watchlistSymbols.length,
            itemBuilder: (context, index) {
              final symbol = _watchlistSymbols[index];
              return _buildBigWatchlistCard(symbol, brightness, index);
            },
          ),
        ),
      ],
    );
  }

  /// Build big watchlist card matching trending stocks design
  Widget _buildBigWatchlistCard(
    String symbol,
    Brightness brightness,
    int index,
  ) {
    final stockData = _stockData[symbol];
    final quote = stockData?['quote'];
    final profile = stockData?['profile'];

    final currentPrice = quote?['c']?.toDouble() ?? 0.0;
    final change = quote?['d']?.toDouble() ?? 0.0;
    final changePercent = quote?['dp']?.toDouble() ?? 0.0;
    final isPositive = changePercent >= 0;

    final companyName = profile?['name'] ?? symbol;
    final isSelected = _selectedForDelete.contains(symbol);

    return GestureDetector(
      onTap: () {
        if (_isDeleteMode) {
          setState(() {
            if (isSelected) {
              _selectedForDelete.remove(symbol);
            } else {
              _selectedForDelete.add(symbol);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StockDetailScreen(symbol: symbol, companyName: companyName),
            ),
          );
        }
      },
      child: Container(
        width: 140, // Same width as trending stocks
        margin: EdgeInsets.only(left: index == 0 ? 10 : 6, right: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isDeleteMode && isSelected
              ? Colors.red.withOpacity(0.2)
              : AppColors.getGreyBG(brightness),
          borderRadius: BorderRadius.circular(12),
          border: _isDeleteMode && isSelected
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkbox when in delete mode
            if (_isDeleteMode)
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Colors.red
                    : AppColors.getText(brightness).withOpacity(0.5),
                size: 24,
              )
            else
              // Company logo (centered at top)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStockColor(symbol),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: _getStockIcon(symbol)),
              ),
            const SizedBox(height: 8),

            // Symbol (centered)
            Text(
              symbol,
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
              '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
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
          padding: EdgeInsets.all(6),
          child: Text(
            'T',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'System',
            ),
          ),
        );
      case 'AAPL':
        return Container(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.apple, color: Colors.white, size: 26),
        );
      case 'NVDA':
        return Container(
          padding: EdgeInsets.all(6),
          child: Text(
            'N',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 'AMD':
        return Container(
          padding: EdgeInsets.all(4),
          child: Text(
            'AMD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      case 'META':
        return Container(
          padding: EdgeInsets.all(6),
          child: Transform.rotate(
            angle: 0.1,
            child: Text(
              'f',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'GOOGL':
        return Container(
          padding: EdgeInsets.all(6),
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      case 'MSFT':
        return Container(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.window, color: Colors.white, size: 24),
        );
      case 'AMZN':
        return Container(
          padding: EdgeInsets.all(6),
          child: Text(
            'a',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(6),
          child: Text(
            symbol.substring(0, 1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
    }
  }
}
