import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pay/pay.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/payment_service.dart';

class AlphaPro extends StatefulWidget {
  final User? user;

  const AlphaPro({Key? key, this.user}) : super(key: key);

  @override
  _AlphaProstate createState() => _AlphaProstate();
}

class _AlphaProstate extends State<AlphaPro> {
  bool _isPro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  void _checkProStatus() async {
    // Use a default user ID if no user is provided (fallback)
    String userID = widget.user?.userID ?? 'default_user';
    bool proStatus = await PaymentService.getProStatus(userID);
    setState(() {
      _isPro = proStatus;
      _isLoading = false;
    });
  }

  void _onPaymentSuccess() {
    setState(() {
      _isPro = true;
    });
  }

  // Google Pay payment dialog
  void _showSimplePaymentDialog(
    BuildContext context,
    String planType,
    String amount,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = themeProvider.brightness;
    final paymentItems = planType.contains('Monthly')
        ? PaymentService.monthlyPaymentItems
        : PaymentService.yearlyPaymentItems;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getBG(brightness),
        title: Text(
          'Complete Payment',
          style: TextStyle(color: AppColors.getText(brightness)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$planType - $amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.getText(brightness),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Pay with Google Pay',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
            ),
            Text(
              'Includes all your saved payment methods',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getText(brightness).withOpacity(0.5),
              ),
            ),
            SizedBox(height: 20),

            // Google Pay Button (Includes Credit Cards, Debit Cards, Bank Accounts)
            SizedBox(
              width: double.infinity,
              child: GooglePayButton(
                paymentConfiguration: PaymentConfiguration.fromJsonString(
                  PaymentService.googlePayConfigString,
                ),
                paymentItems: paymentItems,
                type: GooglePayButtonType.pay,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: (result) {
                  Navigator.pop(context); // Close payment dialog first
                  String userID = widget.user?.userID ?? 'default_user';
                  PaymentService.onPaymentResult(
                    context,
                    result,
                    userID,
                    _onPaymentSuccess,
                  );
                },
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getText(brightness)),
            ),
          ),
        ],
      ),
    );
  }

  // Cancel membership dialog
  void _showCancelMembershipDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = themeProvider.brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getBG(brightness),
        title: Text(
          'Cancel Membership',
          style: TextStyle(
            color: AppColors.getText(brightness),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.getRed(brightness),
              size: 50,
            ),
            SizedBox(height: 15),
            Text(
              'Are you sure you want to cancel your Pro membership?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'You will lose access to:\n• Ad-free experience\n• Advanced research & insights\n• Priority customer support\n• Exclusive features',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getText(brightness).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Membership',
              style: TextStyle(color: AppColors.getGreen(brightness)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelMembership();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getRed(brightness),
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // Cancel membership functionality
  void _cancelMembership() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = themeProvider.brightness;
    String userID = widget.user?.userID ?? 'default_user';

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getBG(brightness),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cancelling membership...',
              style: TextStyle(color: AppColors.getText(brightness)),
            ),
          ],
        ),
      ),
    );

    // Simulate processing time
    await Future.delayed(Duration(seconds: 2));

    // Remove pro status
    await PaymentService.setProStatus(userID, false);

    // Close processing dialog
    Navigator.pop(context);

    // Update UI
    setState(() {
      _isPro = false;
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getBG(brightness),
        title: Text(
          'Membership Cancelled',
          style: TextStyle(color: AppColors.getText(brightness)),
        ),
        content: Text(
          'Your Pro membership has been cancelled. Thank you for being part of AlphaWave Pro!',
          style: TextStyle(color: AppColors.getText(brightness)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.getGreen(brightness)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.getBG(brightness),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AlphaWave',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: AppColors.getText(brightness),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getText(brightness),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Pro',
                style: TextStyle(
                  color: AppColors.getBG(brightness),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  if (_isPro) ...[
                    // Pro User Content
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.getGreen(brightness).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getGreen(brightness),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.getGreen(brightness),
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You are a Pro Member!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getGreen(brightness),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Enjoy all premium features!',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getText(brightness),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Your Pro Features:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness),
                      ),
                    ),
                  ] else ...[
                    // Non-Pro User Content
                    Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'for better experience with AlphaWave',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.getText(brightness),
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  _buildFeature('Ad-free Experience'),
                  _buildFeature('Advanced Research & Exclusive Insights'),
                  _buildFeature('priority Customer Support'),
                  _buildFeature('Early Access to New Features'),
                  _buildFeature('Exclusive Webinars & Workshop'),
                  _buildFeature('Intelligent Alert & Notifications'),
                  _buildFeature('And more...'),
                  const SizedBox(height: 20),

                  if (!_isPro) ...[
                    ///Month
                    _buildPlanCard(
                      context,
                      title: 'Monthly',
                      price: '\$50/ Month',
                      description: 'Month-to-month plan\nIncludes 7-day trial',
                      onUpgrade: () {
                        _showSimplePaymentDialog(
                          context,
                          'Monthly Plan',
                          '\$50.00',
                        );
                      },
                    ),
                    SizedBox(height: 10),

                    ///Year
                    _buildPlanCard(
                      context,
                      title: 'Yearly',
                      price: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$600',
                              style: TextStyle(
                                color: AppColors.getText(
                                  brightness,
                                ).withOpacity(0.5),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            TextSpan(
                              text: '  \$480/ Year',
                              style: TextStyle(
                                color: AppColors.getText(brightness),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      description:
                          'Save 20% when you pay yearly\nIncludes 30-day free trial',
                      onUpgrade: () {
                        _showSimplePaymentDialog(
                          context,
                          'Yearly Plan',
                          '\$480.00',
                        );
                      },
                    ),
                  ] else ...[
                    // Show current subscription status for pro users
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getGreyBG(brightness).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.getGreen(brightness),
                            size: 30,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Subscription',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getText(brightness),
                                  ),
                                ),
                                Text(
                                  'All premium features unlocked',
                                  style: TextStyle(
                                    color: AppColors.getText(
                                      brightness,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Manage Subscription Section
                    Text(
                      'Manage Your Subscription',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getText(brightness),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Cancel Membership Button
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getRed(brightness).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getRed(brightness).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: AppColors.getRed(brightness),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Cancel Membership',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getText(brightness),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You can cancel your Pro membership at any time. You\'ll continue to have access to Pro features until the end of your current billing period.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getText(
                                brightness,
                              ).withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showCancelMembershipDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.getRed(brightness),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                              ),
                              child: Text('Cancel Membership'),
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,)
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFeature(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.getText(brightness),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.getText(brightness),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPlanCard(
  BuildContext context, {
  required String title,
  required dynamic price,
  required String description,
  VoidCallback? onUpgrade,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final brightness = themeProvider.brightness;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.getGreyBG(brightness).withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.getText(brightness),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        price is String
            ? Text(
                price,
                style: TextStyle(
                  color: AppColors.getText(brightness),
                  fontSize: 16,
                ),
              )
            : price,
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: AppColors.getText(brightness)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: onUpgrade != null
                  ? Colors.blue
                  : AppColors.getGreyBG(brightness),
              foregroundColor: onUpgrade != null
                  ? Colors.white
                  : AppColors.getText(brightness),
            ),
            child: Text(onUpgrade != null ? 'Upgrade' : 'Active'),
          ),
        ),
      ],
    ),
  );
}
