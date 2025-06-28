/// Represents a user account with basic information
///
/// Following Lectures.md data model specifications:
/// User: userId, username, email, password_hash
/// Simplified for educational purposes - keeping core fields only
class User {
  /// Unique identifier for the user
  String userId;

  /// User's username for login
  String username;

  /// User's email address
  String email;

  /// User's password (simplified for educational project)
  String password;

  /// Date when the account was created
  DateTime createdAt;

  /// Creates a new User instance
  ///
  /// [userId] - Unique identifier for the user
  /// [username] - User's username for login
  /// [email] - User's email address
  /// [password] - User's password
  /// [createdAt] - Optional creation date, defaults to current time
  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create User from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, email: $email}';
  }
}
