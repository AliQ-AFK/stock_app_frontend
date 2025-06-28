import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/theme_provider.dart';
import 'session_manager.dart';
import 'features/authentication/presentation/screens/landing_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; //reads api safely

/// Main entry point for the AlphaWave trading application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize database and demo data
  await initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: AlphaWaveApp(),
    ),
  );
}

/// Initializes the application with session manager
///
/// Following lectures.md requirements for simple in-memory approach
/// and performance criteria: "API Response Time: Under 500ms"
Future<void> initializeApp() async {
  try {
    print('Initializing AlphaWave application...');

    // Initialize session manager for in-memory storage
    final sessionManager = SessionManager();
    print('Session manager initialized successfully');

    print('Application initialization complete');
  } catch (e) {
    print('Error during app initialization: $e');
    // Don't prevent app startup, but log the error
  }
}

/// Root widget for the AlphaWave trading application
///
/// This widget configures the MaterialApp with theme settings
/// and sets the landing screen as the initial route
class AlphaWaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Update system UI overlay style based on current theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            // Status bar
            statusBarColor: AppColors.getBG(themeProvider.brightness),
            statusBarIconBrightness: themeProvider.isLightMode
                ? Brightness.dark
                : Brightness.light,
            statusBarBrightness: themeProvider.isLightMode
                ? Brightness.light
                : Brightness.dark,

            // Navigation bar
            systemNavigationBarColor: AppColors.getBG(themeProvider.brightness),
            systemNavigationBarIconBrightness: themeProvider.isLightMode
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarDividerColor: AppColors.getBG(
              themeProvider.brightness,
            ),
          ),
        );

        return MaterialApp(
          title: 'AlphaWave Trading',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: AppColors.lightBG,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.lightBG,
              foregroundColor: AppColors.lightText,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColors.lightBG,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: AppColors.lightBG,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: AppColors.darkBG,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.darkBG,
              foregroundColor: AppColors.darkText,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColors.darkBG,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: AppColors.darkBG,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            ),
          ),
          home: LandingScreen(),
        );
      },
    );
  }
}
