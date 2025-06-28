import '../models/user.dart';

/// Manages users with in-memory storage
///
/// Following Lectures.md recommendations for AuthService functionality:
/// - User registration and login
/// - Secure authentication logic
/// - Simple in-memory storage for educational purposes
class UserService {
  /// Static in-memory storage for users
  static final List<User> _users = [
    User(
      userId: "1",
      username: "johndoe",
      email: "john@example.com",
      password: "password123",
    ),
    User(
      userId: "2",
      username: "janesmith",
      email: "jane@example.com",
      password: "password456",
    ),
    User(
      userId: "3",
      username: "testuser",
      email: "test@test.com",
      password: "123456",
    ),
  ];

  /// Currently logged in user
  static User? _currentUser;

  /// Authenticates a user with email and password
  ///
  /// Following Lectures.md requirement: "Login: Registered users can log in"
  /// [email] - Email address to authenticate
  /// [password] - Password to verify
  /// Returns the authenticated user or null if authentication fails
  static Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
      _currentUser = user;
      print('UserService: User ${user.username} logged in successfully');
      return user;
    } catch (e) {
      print('UserService: Login failed for $email');
      return null;
    }
  }

  /// Checks if an email already exists in the system
  ///
  /// [email] - Email address to check
  /// Returns true if email exists, false otherwise
  static bool emailExists(String email) {
    try {
      _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if a username already exists in the system
  ///
  /// [username] - Username to check
  /// Returns true if username exists, false otherwise
  static bool usernameExists(String username) {
    try {
      _users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Registers a new user
  ///
  /// Following Lectures.md requirement: "Registration: Users can create an account"
  /// [username] - Username for the new user
  /// [email] - Email address for the new user
  /// [password] - Password for the new user
  /// Returns the registered user
  static Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    final newUser = User(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      password: password,
    );

    _users.add(newUser);
    _currentUser = newUser;
    print('UserService: User ${newUser.username} registered successfully');
    return newUser;
  }

  /// Logs out the current user
  static void logout() {
    if (_currentUser != null) {
      print('UserService: User ${_currentUser!.username} logged out');
      _currentUser = null;
    }
  }

  /// Gets the currently logged in user
  ///
  /// Returns the current user or null if no user is logged in
  static User? getCurrentUser() {
    return _currentUser;
  }

  /// Gets all registered users (for debugging)
  static List<User> getAllUsers() {
    return List.from(_users);
  }
}
