import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';
import 'package:stock_app_frontend/features/profile/presentation/screens/my_account_screen.dart';
import 'package:stock_app_frontend/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:stock_app_frontend/features/stocks/presentation/screens/my_stocks_screen.dart';
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
        return _buildPortfolioScreen();
      case 2:
        return _buildPlaceholderScreen('News', Icons.article);
      case 3:
        return MyAccountScreen(user: widget.user);
      default:
        return DashboardScreen(user: widget.user);
    }
  }

  /// Builds the Portfolio screen with stock options
  Widget _buildPortfolioScreen() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;
    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Dashboard title
            Text(
              'Portfolio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),

            const Spacer(),
            // Search container
            Container(
              width: 155,
              height: 36,
              child: TextField(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: isLightMode ? Colors.black87 : Colors.white70,
                ),
                textAlignVertical: TextAlignVertical
                    .center, // ✅ ช่วยจัด text ให้อยู่กลางแนวดิ่ง
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.getText(brightness).withOpacity(0.5),
                    size: 20,
                  ),
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.getText(brightness).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.getText(brightness),
                size: 28,
              ),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Portfolio Overview',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // My Stocks Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyStocksScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'My Stocks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Watchlist Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WatchlistScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'My Watchlist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
