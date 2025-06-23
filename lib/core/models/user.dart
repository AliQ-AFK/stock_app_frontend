/// Represents a user account with basic information
///
/// This class stores user registration details and authentication information
/// for the AlphaWave trading application.
class User {
  /// Unique identifier for the user
  String userID;

  /// User's full name
  String name;

  /// User's email address
  String email;

  /// User's username for login
  String username;

  /// User's password (plain text for simplicity in educational project)
  String password;

  /// User's phone number
  String phoneNumber;

  /// Date when the account was created
  DateTime createdAt;

  /// Date of the user's last login
  DateTime lastLogin;

  /// Creates a new User instance
  ///
  /// [userID] - Unique identifier for the user
  /// [name] - User's full name
  /// [email] - User's email address
  /// [username] - User's username for login
  /// [password] - User's password
  /// [phoneNumber] - User's phone number
  /// [createdAt] - Optional creation date, defaults to current time
  /// [lastLogin] - Optional last login date, defaults to current time
  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();

  /// Updates the user's profile information
  ///
  /// [name] - New name for the user
  /// [email] - New email for the user
  /// [phoneNumber] - New phone number for the user
  void updateProfile(String name, String email, String phoneNumber) {
    this.name = name;
    this.email = email;
    this.phoneNumber = phoneNumber;
  }

  /// Updates the last login timestamp to the current time
  void updateLastLogin() {
    lastLogin = DateTime.now();
  }
}
