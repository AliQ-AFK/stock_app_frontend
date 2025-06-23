import 'package:flutter/material.dart';

/// Landing screen for the AlphaWave trading application
///
/// This screen displays the app logo, welcome message, and authentication
/// options. It adapts to light and dark themes automatically.
class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    // Check current theme brightness for asset selection
    final brightness = MediaQuery.of(context).platformBrightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLightMode ? Colors.grey[100] : Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Top spacer
            Spacer(flex: 2),

            // AlphaWave Logo
            Container(
              width: 300,
              height: 300,
              child: Image.asset(
                isLightMode
                    ? 'assets/logos/light_logo.png'
                    : 'assets/logos/dark_logo.png',
                fit: BoxFit.contain,
              ),
            ),

            // Middle spacer
            Spacer(flex: 1),

            // Sign in button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to sign in screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLightMode
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    foregroundColor: isLightMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Sign up row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 16,
                    color: isLightMode ? Colors.black87 : Colors.white70,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to sign up screen
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Bottom graph
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                child: Image.asset(
                  isLightMode
                      ? 'assets/logos/light_start_page_graph.png'
                      : 'assets/logos/dark_start_page_graph.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
