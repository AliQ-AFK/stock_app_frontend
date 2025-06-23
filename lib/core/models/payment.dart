import 'enums/payment_enums.dart';

/// Simple payment record for transactions
///
/// This class tracks payment information for premium subscriptions
/// and other monetary transactions within the application.
class Payment {
  /// Unique identifier for the payment
  String paymentID;

  /// ID of the user who made the payment
  String userID;

  /// Optional ID of the associated transaction
  String? transactionID;

  /// Method used for payment
  PaymentMethod paymentMethod;

  /// Amount of the payment
  double amount;

  /// Currency of the payment
  String currency;

  /// Current status of the payment
  PaymentStatus status;

  /// Date and time when the payment was made
  DateTime paymentDate;

  /// Creates a new Payment instance
  ///
  /// [paymentID] - Unique identifier for the payment
  /// [userID] - ID of the user who made the payment
  /// [transactionID] - Optional ID of the associated transaction
  /// [paymentMethod] - Method used for payment
  /// [amount] - Amount of the payment
  /// [currency] - Currency of the payment, defaults to "USD"
  /// [status] - Payment status, defaults to completed
  /// [paymentDate] - Optional payment date, defaults to current time
  Payment({
    required this.paymentID,
    required this.userID,
    this.transactionID,
    required this.paymentMethod,
    required this.amount,
    this.currency = "USD",
    this.status = PaymentStatus.completed,
    DateTime? paymentDate,
  }) : paymentDate = paymentDate ?? DateTime.now();

  /// Converts the payment to a map representation
  ///
  /// Returns a map containing key payment information
  Map<String, dynamic> toMap() {
    return {
      'paymentID': paymentID,
      'amount': amount,
      'method': paymentMethod.toString(),
      'status': status.toString(),
      'date': paymentDate,
    };
  }
}
