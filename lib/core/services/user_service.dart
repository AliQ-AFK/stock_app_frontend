import '../models/user.dart';

/// Manages users with in-memory storage
///
/// This service provides user authentication and management functionality
/// using static in-memory storage for educational purposes.
class UserService {
  /// Static in-memory storage for users
  static final List<User> _users = [
    User(
      userID: "1",
      name: "John Doe",
      email: "john@example.com",
      username: "johndoe",
      password: "password123",
      phoneNumber: "1234567890",
    ),
    User(
      userID: "2",
      name: "Jane Smith",
      email: "jane@example.com",
      username: "janesmith",
      password: "password456",
      phoneNumber: "0987654321",
    ),
  ];

  /// Currently logged in user
  static User? _currentUser;

  /// Authenticates a user with username and password
  ///
  /// [username] - Username to authenticate
  /// [password] - Password to verify
  /// Returns the authenticated user or null if authentication fails
  static Future<User?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      user.updateLastLogin();
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Registers a new user
  ///
  /// [newUser] - User object to register
  /// Returns the registered user
  static Future<User> register(User newUser) async {
    await Future.delayed(Duration(seconds: 1));
    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  /// Logs out the current user
  static void logout() {
    _currentUser = null;
  }

  /// Gets the currently logged in user
  ///
  /// Returns the current user or null if no user is logged in
  static User? getCurrentUser() {
    return _currentUser;
  }

  /// Updates a user's profile information
  ///
  /// [updatedUser] - User object with updated information
  static Future<void> updateProfile(User updatedUser) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.userID == updatedUser.userID);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.userID == updatedUser.userID) {
        _currentUser = updatedUser;
      }
    }
  }
}
