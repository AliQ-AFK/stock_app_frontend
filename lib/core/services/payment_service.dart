import '../models/payment.dart';
import '../models/enums/payment_enums.dart';

/// Simulates payment processing
///
/// This service provides mock payment processing functionality
/// for premium subscriptions and other transactions.
class PaymentService {
  /// Static storage for payments
  static final List<Payment> _payments = [];

  /// Processes a payment transaction
  ///
  /// [userID] - ID of the user making the payment
  /// [amount] - Amount to be paid
  /// [method] - Payment method to use
  /// [transactionID] - Optional associated transaction ID
  /// Returns the processed payment
  static Future<Payment> processPayment({
    required String userID,
    required double amount,
    required PaymentMethod method,
    String? transactionID,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    final payment = Payment(
      paymentID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      transactionID: transactionID,
      paymentMethod: method,
      amount: amount,
    );

    _payments.add(payment);
    return payment;
  }

  /// Retrieves all payments for a user
  ///
  /// [userID] - ID of the user whose payments to retrieve
  /// Returns a list of payments sorted by date (newest first)
  static Future<List<Payment>> getUserPayments(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _payments.where((p) => p.userID == userID).toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }
}
