import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pay/pay.dart';

/// Payment Service for AlphaWave Pro Subscriptions
class PaymentService {
  // Pro status management - USER SPECIFIC
  static Future<void> setProStatus(String userID, bool isPro) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'is_pro_user_$userID'; // User-specific key
    await prefs.setBool(key, isPro);
  }

  static Future<bool> getProStatus(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'is_pro_user_$userID'; // User-specific key
    return prefs.getBool(key) ?? false;
  }

  // Payment items for different plans
  static const monthlyPaymentItems = [
    PaymentItem(
      label: 'AlphaWave Pro Monthly',
      amount: '50.00',
      status: PaymentItemStatus.final_price,
    ),
  ];

  static const yearlyPaymentItems = [
    PaymentItem(
      label: 'AlphaWave Pro Yearly',
      amount: '480.00',
      status: PaymentItemStatus.final_price,
    ),
  ];

  // Google Pay configuration (Test Mode - Safe for Development)
  static const String googlePayConfigString = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "exampleMerchantId"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "12345678901234567890",
      "merchantName": "AlphaWave"
    },
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "50.00",
      "currencyCode": "USD",
      "countryCode": "US"
    }
  }
}''';

  // Simple payment success handler
  static Future<void> onPaymentResult(
    BuildContext context,
    Map<String, dynamic> result,
    String userID,
    VoidCallback onSuccess,
  ) async {
    try {
      // Save pro status for specific user
      await setProStatus(userID, true);

      // Call success callback
      onSuccess();

      // Show simple success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Welcome to AlphaWave Pro!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment processing error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Simple mock payment for demo
  static Future<void> processMockPayment(
    BuildContext context,
    String userID,
    VoidCallback onSuccess,
  ) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Processing payment...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate processing
    await Future.delayed(Duration(seconds: 2));

    // Process payment for specific user
    await setProStatus(userID, true);
    onSuccess();

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! Welcome to AlphaWave Pro!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
