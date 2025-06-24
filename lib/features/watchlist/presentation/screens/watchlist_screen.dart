import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/models/stock.dart';
import 'package:stock_app_frontend/core/services/stock_data_service.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Stock> _watchlistStocks = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  Set<String> _selectedStocks = {};

  @override
  void initState() {
    super.initState();
    _loadWatchlistData();
  }

  Future<void> _loadWatchlistData() async {
    try {
      // Load all stocks and take first 12 as watchlist
      final allStocks = await StockDataService.getAllStocks();
      setState(() {
        _watchlistStocks = allStocks.take(12).toList();
        _isLoading = false;
      });
    } catch (e) {
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
      appBar: AppBar(
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
        title: Row(
          children: [
            Text(
              'My Watchlist',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),
            Spacer(),
            Container(
              width: 111,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.getBG(brightness),
                border: Border.all(
                  color: AppColors.getText(brightness),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Icon(
                      Icons.search,
                      color: AppColors.getText(brightness),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header section with count and edit
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 29, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_watchlistStocks.length} Companies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getText(brightness),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                      if (!_isEditMode) {
                        _selectedStocks.clear();
                      }
                    });
                  },
                  child: Text(
                    _isEditMode ? 'Done' : 'Edit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Delete button (shown when in edit mode and stocks are selected)
          if (_isEditMode && _selectedStocks.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
              child: ElevatedButton(
                onPressed: () => _deleteSelectedStocks(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getRed(brightness),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Delete ${_selectedStocks.length} Stock${_selectedStocks.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          // Stock list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 26),
                    itemCount: _watchlistStocks.length,
                    itemBuilder: (context, index) {
                      final stock = _watchlistStocks[index];
                      return _buildStockItem(stock, brightness);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedStocks() {
    setState(() {
      _watchlistStocks.removeWhere(
        (stock) => _selectedStocks.contains(stock.stockID),
      );
      _selectedStocks.clear();
      _isEditMode = false;
    });
  }

  Widget _buildStockItem(Stock stock, Brightness brightness) {
    final changePercent = stock.calculateChangePercent();
    final isPositive = changePercent >= 0;
    final isSelected = _selectedStocks.contains(stock.stockID);

    return Container(
      height: 82,
      margin: EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          // Checkbox (shown in edit mode)
          if (_isEditMode)
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedStocks.remove(stock.stockID);
                    } else {
                      _selectedStocks.add(stock.stockID);
                    }
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.getText(brightness)
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.getText(brightness),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: AppColors.getBG(brightness),
                          size: 16,
                        )
                      : null,
                ),
              ),
            ),

          // Stock icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getStockColor(stock.symbol),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: Center(child: _getStockIcon(stock.symbol)),
          ),

          SizedBox(width: 20),

          // Stock info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stock.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getText(brightness),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stock.company,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.getText(brightness),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Price and percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stock.currentPrice.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getText(brightness),
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 12,
                    color: isPositive
                        ? AppColors.getGreen(brightness)
                        : AppColors.getRed(brightness),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPositive
                          ? AppColors.getGreen(brightness)
                          : AppColors.getRed(brightness),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        return Colors.grey[600]!;
    }
  }

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
        return Icon(Icons.apple, color: Colors.white, size: 20);
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
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
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
      case 'GOOGL':
        return Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      case 'MSFT':
        return Icon(Icons.window, color: Colors.white, size: 18);
      case 'AMZN':
        return Text(
          'a',
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
