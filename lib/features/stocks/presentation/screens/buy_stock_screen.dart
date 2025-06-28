import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/session_manager.dart';

/// Buy Stock Screen - Matches exact Figma design
/// Following lectures.md requirement: "Buy/Sell Orders: Execute market and limit orders"
/// Implements Google Pay integration for mock payments
class BuyStockScreen extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final String? companyName;

  const BuyStockScreen({
    Key? key,
    required this.symbol,
    required this.currentPrice,
    this.companyName,
  }) : super(key: key);

  @override
  _BuyStockScreenState createState() => _BuyStockScreenState();
}

class _BuyStockScreenState extends State<BuyStockScreen> {
  // Core state following lectures.md "core features first"
  int _quantity = 1;
  bool _isProcessing = false;
  bool _showGooglePay = false; // New state for two-step flow
  final SessionManager _sessionManager = SessionManager();

  // Google Pay payment configuration
  late final Future<String> _googlePayConfigFuture;

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture = _loadGooglePayConfig();
  }

  /// Load Google Pay configuration from assets
  Future<String> _loadGooglePayConfig() async {
    try {
      final String config = await rootBundle.loadString(
        'assets/payment/default_google_payment_profile.json',
      );
      final Map<String, dynamic> configData = json.decode(config);

      // Update the transaction amount dynamically
      configData['data']['transactionInfo']['totalPrice'] =
          (_quantity * widget.currentPrice).toStringAsFixed(2);

      // Return the complete configuration including 'provider' key
      return json.encode(configData);
    } catch (e) {
      print('Error loading Google Pay config: $e');
      rethrow;
    }
  }

  /// Calculate total purchase amount
  double get _totalAmount => _quantity * widget.currentPrice;

  /// Increment quantity
  void _incrementQuantity() {
    if (_quantity < 999) {
      // Reasonable limit
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

  /// Handle successful payment
  /// Following lectures.md requirement: "Real-time Execution: Orders are executed in real-time"
  Future<void> _onPaymentResult(Map<String, dynamic> result) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      print('Payment successful, processing stock purchase...');

      // Mock delay to simulate payment processing
      await Future.delayed(const Duration(milliseconds: 500));

      // Execute stock purchase in session manager
      final success = await _sessionManager.buyStock(
        widget.symbol,
        _quantity.toDouble(),
        widget.currentPrice,
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully purchased $_quantity shares of ${widget.symbol}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Close the buy screen
          Navigator.of(
            context,
          ).pop(true); // Return true to indicate successful purchase
        }
      } else {
        throw Exception('Failed to save purchase to session');
      }
    } catch (e) {
      print('Error processing purchase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Handle payment errors
  void _onPaymentError(Object error) {
    print('Payment error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(brightness),
            const SizedBox(height: 24),
            _buildQuantitySelector(brightness),
            const SizedBox(height: 24),
            _buildPriceDisplay(brightness),
            const SizedBox(height: 32),
            _buildActionButtons(brightness),
          ],
        ),
      ),
    );
  }

  /// Build header section - matches Figma design
  Widget _buildHeader(Brightness brightness) {
    return Column(
      children: [
        Text(
          'Buying Stocks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getText(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set the prefer amount',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getText(brightness).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Build quantity selector - matches Figma design exactly
  Widget _buildQuantitySelector(Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.getText(brightness).withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          GestureDetector(
            onTap: _decrementQuantity,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getText(brightness),
                  ),
                ),
              ),
            ),
          ),

          // Quantity display
          Container(
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getText(brightness),
                ),
              ),
            ),
          ),

          // Plus button
          GestureDetector(
            onTap: _incrementQuantity,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getText(brightness),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build price display - matches Figma design
  Widget _buildPriceDisplay(Brightness brightness) {
    return Column(
      children: [
        Text(
          'Price: \$${_totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getText(brightness),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.symbol} • \$${widget.currentPrice.toStringAsFixed(2)} per share',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getText(brightness).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Build action buttons - matches Figma design exactly
  Widget _buildActionButtons(Brightness brightness) {
    return Column(
      children: [
        // Main action buttons row - matching Figma exactly
        Row(
          children: [
            // Cancel button - matching Figma style
            Expanded(
              child: Container(
                height: 44,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.getText(brightness).withOpacity(0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Confirm button - matching Figma style
            Expanded(
              child: Container(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirmPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getText(brightness),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getBG(brightness),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Google Pay button appears after confirming
        if (_showGooglePay) ...[
          const SizedBox(height: 16),
          _buildGooglePaySection(brightness),
        ],
      ],
    );
  }

  /// Handle confirm button press - shows Google Pay
  void _handleConfirmPress() {
    setState(() {
      _showGooglePay = true;
    });
  }

  /// Build Google Pay section that appears after confirm
  Widget _buildGooglePaySection(Brightness brightness) {
    return Column(
      children: [
        // Divider with "Pay with" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.getText(brightness).withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pay with',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getText(brightness).withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.getText(brightness).withOpacity(0.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Google Pay button
        _isProcessing
            ? Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : FutureBuilder<String>(
                future: _googlePayConfigFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      height: 48,
                      child: GooglePayButton(
                        paymentConfiguration:
                            PaymentConfiguration.fromJsonString(snapshot.data!),
                        paymentItems: [
                          PaymentItem(
                            label: '${widget.symbol} Stocks',
                            amount: _totalAmount.toStringAsFixed(2),
                            status: PaymentItemStatus.final_price,
                          ),
                        ],
                        type: GooglePayButtonType.buy,
                        margin: EdgeInsets.zero,
                        onPaymentResult: _onPaymentResult,
                        onError: (Object? error) =>
                            _onPaymentError(error ?? 'Unknown error'),
                        loadingIndicator: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Fallback button if Google Pay config fails
                    return Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _onPaymentResult({'status': 'success'});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Complete Purchase',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                },
              ),
      ],
    );
  }
}

/// Helper function to show buy stock dialog
/// Following lectures.md UI/UX requirements for clean interaction patterns
Future<bool?> showBuyStockDialog({
  required BuildContext context,
  required String symbol,
  required double currentPrice,
  String? companyName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BuyStockScreen(
      symbol: symbol,
      currentPrice: currentPrice,
      companyName: companyName,
    ),
  );
}
