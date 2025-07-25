import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'sign_in.dart';
import 'sign_up1.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              isLightMode
                  ? 'assets/images/light_first_page.jpeg'
                  : 'assets/images/dark_first_page.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Authentication overlay positioned in center-bottom area
          Positioned(
            left: 0,
            right: 0,
            bottom:
                MediaQuery.of(context).size.height * 0.32, // Position higher up
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLightMode
                            ? Colors.grey[300]
                            : Colors.grey[700],
                        foregroundColor: isLightMode
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp1()),
                          );
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
