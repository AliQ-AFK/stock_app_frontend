/// Payment method enumeration for different payment types
enum PaymentMethod {
  /// Credit/debit card payment
  card,

  /// Bank transfer payment
  bank,

  /// Digital wallet payment
  wallet,
}

/// Payment status enumeration for tracking payment states
enum PaymentStatus {
  /// Payment is pending processing
  pending,

  /// Payment has been completed successfully
  completed,

  /// Payment has failed
  failed,
}
