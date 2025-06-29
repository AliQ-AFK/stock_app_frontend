import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/trading_service.dart';
import 'package:stock_app_frontend/session_manager.dart';

/// Sell Stock Screen - Matches design pattern of buy screen
/// Following lectures.md requirement: "Buy/Sell Orders: Execute market and limit orders"
/// Implements selling functionality with validation
class SellStockScreen extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final String? companyName;

  const SellStockScreen({
    Key? key,
    required this.symbol,
    required this.currentPrice,
    this.companyName,
  }) : super(key: key);

  @override
  _SellStockScreenState createState() => _SellStockScreenState();
}

class _SellStockScreenState extends State<SellStockScreen> {
  // Core state following lectures.md "core features first"
  double _quantity = 1.0;
  bool _isProcessing = false;
  double _maxQuantity = 0.0;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _loadCurrentHoldings();
  }

  /// Load current holdings to determine max sellable quantity
  void _loadCurrentHoldings() {
    final portfolio = _sessionManager.getPortfolio();
    final stock = portfolio.firstWhere(
      (stock) => stock.symbol == widget.symbol,
      orElse: () => PortfolioStock(
        symbol: widget.symbol,
        companyName: widget.companyName ?? widget.symbol,
        logoUrl: '',
        quantity: 0.0,
        averagePurchasePrice: 0.0,
      ),
    );

    setState(() {
      _maxQuantity = stock.quantity;
      _quantity = _maxQuantity > 0 ? 1.0 : 0.0;
    });
  }

  /// Calculate total sale amount
  double get _totalAmount => _quantity * widget.currentPrice;

  /// Increment quantity
  void _incrementQuantity() {
    if (_quantity < _maxQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  /// Decrement quantity
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  /// Handle sell stock execution
  /// Following lectures.md requirement: "Real-time Execution: Orders are executed in real-time"
  Future<void> _executeSell() async {
    // Validation checks
    if (_maxQuantity <= 0) {
      _showErrorMessage('You do not own any shares of ${widget.symbol}');
      return;
    }

    if (_quantity > _maxQuantity) {
      _showErrorMessage(
        'Cannot sell $_quantity shares. You only own $_maxQuantity shares.',
      );
      return;
    }

    if (_quantity <= 0) {
      _showErrorMessage('Please enter a valid quantity to sell');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('Executing sell order: $_quantity shares of ${widget.symbol}');

      // Execute sell order through TradingService
      final success = await TradingService.executeSellOrder(
        symbol: widget.symbol,
        quantity: _quantity,
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully sold $_quantity shares of ${widget.symbol} for \$${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Close the sell screen
          Navigator.of(
            context,
          ).pop(true); // Return true to indicate successful sale
        }
      } else {
        _showErrorMessage('Failed to execute sell order. Please try again.');
      }
    } catch (e) {
      print('Error executing sell order: $e');
      _showErrorMessage('An error occurred while selling. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handle manual input
  void _onQuantityChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0 && parsed <= _maxQuantity) {
      setState(() {
        _quantity = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    // Return early if no holdings
    if (_maxQuantity <= 0) {
      return _buildNoHoldingsDialog(brightness);
    }

    return _buildSellDialog(brightness);
  }

  /// Build dialog for when user has no holdings
  Widget _buildNoHoldingsDialog(Brightness brightness) {
    return AlertDialog(
      backgroundColor: AppColors.getWidgetBG(brightness),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Cannot Sell ${widget.symbol}',
        style: TextStyle(
          color: AppColors.getText(brightness),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'You do not currently own any shares of ${widget.symbol}.',
        style: TextStyle(color: AppColors.getText(brightness).withOpacity(0.7)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('OK', style: TextStyle(color: AppColors.lightGreen)),
        ),
      ],
    );
  }

  /// Build main sell dialog
  Widget _buildSellDialog(Brightness brightness) {
    return AlertDialog(
      backgroundColor: AppColors.getWidgetBG(brightness),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sell ${widget.symbol}',
            style: TextStyle(
              color: AppColors.getText(brightness),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          if (widget.companyName != null)
            Text(
              widget.companyName!,
              style: TextStyle(
                color: AppColors.getText(brightness).withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'You own $_maxQuantity shares',
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current price display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.getBG(brightness),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Price:',
                  style: TextStyle(
                    color: AppColors.getText(brightness).withOpacity(0.7),
                  ),
                ),
                Text(
                  '\$${widget.currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.getText(brightness),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity:',
                style: TextStyle(
                  color: AppColors.getText(brightness),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? _decrementQuantity : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _quantity > 1 ? AppColors.lightGreen : Colors.grey,
                    ),
                  ),
                  Container(
                    width: 60,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: _onQuantityChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: _quantity.toInt().toString(),
                      ),
                      style: TextStyle(color: AppColors.getText(brightness)),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < _maxQuantity
                        ? _incrementQuantity
                        : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _quantity < _maxQuantity
                          ? AppColors.lightGreen
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total amount
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sale Amount:',
                  style: TextStyle(
                    color: AppColors.getText(brightness),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _executeSell,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Sell Stock'),
        ),
      ],
    );
  }
}

/// Helper function to show sell stock dialog
Future<bool?> showSellStockDialog({
  required BuildContext context,
  required String symbol,
  required double currentPrice,
  String? companyName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SellStockScreen(
      symbol: symbol,
      currentPrice: currentPrice,
      companyName: companyName,
    ),
  );
}
