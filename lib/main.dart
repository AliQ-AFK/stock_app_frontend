import 'package:flutter/material.dart';
import 'core/services/portfolio_manager_service.dart';
import 'core/services/watchlist_service.dart';
import 'features/authentication/presentation/screens/landing_screen.dart';

/// Main entry point for the AlphaWave trading application
void main() {
  // Initialize all demo data
  initializeApp();
  runApp(AlphaWaveApp());
}

/// Initializes the application with demo data
///
/// This function sets up the in-memory data for the educational
/// trading simulator as specified in the UML documentation
void initializeApp() {
  // Initialize demo data for services
  PortfolioManagerService.initializeDemoData();
  WatchlistService.initializeDemoData();
}

/// Root widget for the AlphaWave trading application
///
/// This widget configures the MaterialApp with theme settings
/// and sets the landing screen as the initial route
class AlphaWaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlphaWave Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingScreen(),
    );
  }
}
