import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/session_manager.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';
import 'package:stock_app_frontend/features/profile/presentation/screens/my_account_screen.dart';
import 'package:stock_app_frontend/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/my_stocks_screen.dart';
import 'package:stock_app_frontend/features/dashboard/presentation/screens/portfolio_screen.dart';
import 'package:stock_app_frontend/features/news/presentation/screens/news_screen.dart';
import '../../../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import '../widgets/bottom_navigation.dart';

/// Main screen container with bottom navigation
///
/// This screen serves as the main container after user login,
/// providing navigation between different sections of the app.
class MainScreen extends StatefulWidget {
  /// The currently logged-in user
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    // Start session with user's username following Lectures.md simplicity
    _sessionManager.startSession(widget.user.username);
    print('Started session for user: ${widget.user.username}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  /// Builds the current screen based on selected tab
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          user: widget.user,
          onNavigateToNews: () {
            setState(() {
              _currentIndex = 2; // Switch to News tab
            });
          },
        );
      case 1:
        return PortfolioScreen(
          user: widget.user,
        ); // Use the proper Figma-designed Portfolio screen
      case 2:
        return NewsScreen(user: widget.user);
      case 3:
        return MyAccountScreen(user: widget.user);
      default:
        return DashboardScreen(
          user: widget.user,
          onNavigateToNews: () {
            setState(() {
              _currentIndex = 2; // Switch to News tab
            });
          },
        );
    }
  }

  /// Builds a placeholder screen for unimplemented tabs
  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
