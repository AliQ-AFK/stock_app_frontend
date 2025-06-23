import 'enums/transaction_enums.dart';

/// Records buy/sell activities
///
/// This class tracks individual trading transactions including
/// type, quantity, price, and commission information.
class Transaction {
  /// Unique identifier for the transaction
  String transactionID;

  /// ID of the user who made the transaction
  String userID;

  /// ID of the portfolio this transaction affects
  String portfolioID;

  /// ID of the stock being traded
  String stockID;

  /// Type of transaction (buy or sell)
  TransactionType type;

  /// Number of shares traded
  double quantity;

  /// Price per share at time of transaction
  double price;

  /// Commission fee for the transaction
  double commission;

  /// Date and time when the transaction occurred
  DateTime transactionDate;

  /// Current status of the transaction
  TransactionStatus status;

  /// Creates a new Transaction instance
  ///
  /// [transactionID] - Unique identifier for the transaction
  /// [userID] - ID of the user who made the transaction
  /// [portfolioID] - ID of the portfolio this transaction affects
  /// [stockID] - ID of the stock being traded
  /// [type] - Type of transaction (buy or sell)
  /// [quantity] - Number of shares traded
  /// [price] - Price per share at time of transaction
  /// [commission] - Commission fee, defaults to 0.0
  /// [transactionDate] - Optional transaction date, defaults to current time
  /// [status] - Transaction status, defaults to completed
  Transaction({
    required this.transactionID,
    required this.userID,
    required this.portfolioID,
    required this.stockID,
    required this.type,
    required this.quantity,
    required this.price,
    this.commission = 0.0,
    DateTime? transactionDate,
    this.status = TransactionStatus.completed,
  }) : transactionDate = transactionDate ?? DateTime.now();

  /// Calculates the total amount of the transaction
  ///
  /// Returns the total cost including shares value and commission
  double get totalAmount {
    return (quantity * price) + commission;
  }

  /// Converts the transaction to a map representation
  ///
  /// Returns a map containing key transaction information
  Map<String, dynamic> toMap() {
    return {
      'transactionID': transactionID,
      'type': type.toString(),
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'date': transactionDate,
    };
  }
}
