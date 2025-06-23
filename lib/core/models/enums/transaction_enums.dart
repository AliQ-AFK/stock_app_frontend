/// Transaction type enumeration for buy and sell operations
enum TransactionType {
  /// Buy transaction type
  buy,

  /// Sell transaction type
  sell,
}

/// Transaction status enumeration for tracking transaction states
enum TransactionStatus {
  /// Transaction is pending processing
  pending,

  /// Transaction has been completed successfully
  completed,

  /// Transaction has failed
  failed,
}
