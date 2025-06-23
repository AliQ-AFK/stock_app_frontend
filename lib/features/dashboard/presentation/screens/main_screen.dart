import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/models/user.dart';
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
        return DashboardScreen(user: widget.user);
      case 1:
        return _buildPlaceholderScreen('Analytics', Icons.bar_chart);
      case 2:
        return _buildPlaceholderScreen('Messages', Icons.mail);
      case 3:
        return _buildPlaceholderScreen('Profile', Icons.person);
      default:
        return DashboardScreen(user: widget.user);
    }
  }

  /// Builds a placeholder screen for unimplemented tabs
  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
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
