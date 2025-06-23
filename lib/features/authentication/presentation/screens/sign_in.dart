import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import '../../../dashboard/presentation/screens/main_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenstate createState() => _SignInScreenstate();
}

class _SignInScreenstate extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    // Check current theme brightness for asset selection
    final brightness = MediaQuery.of(context).platformBrightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.getBG(brightness),
        title: Text(
          'Sign in',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: isLightMode ? Colors.black87 : Colors.white70,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Authentication overlay positioned in center-bottom area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 70),

                  ///Email section
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      hintText: 'Type your Email',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  ///Password section
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      hintText: 'Type your Password',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  /// forget password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement Forget Password
                      },
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  ///Sign in Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement proper authentication
                        // For demo purposes, navigate to dashboard with dummy user
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(
                              user: User(
                                userID: "1",
                                name: "Rebecca Smith",
                                email: "rebecca@example.com",
                                username: "rebecca",
                                password: "password",
                                phoneNumber: "1234567890",
                              ),
                            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 85,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  /// Social media login
                  Center(
                    child: Text(
                      'Or sign in using',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: isLightMode ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement Facebook
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.facebookF,
                          color: isLightMode ? Colors.black87 : Colors.white70,
                          size: 33,
                        ),
                      ),
                      SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: CircleBorder(),
                            splashColor: Colors.grey.withOpacity(0.3),
                            onTap: () {
                              // TODO: Implement Google
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: Image.asset(
                                    'assets/logos/google_login.png',
                                    height: 35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Implement Twitter
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.twitter,
                            color: isLightMode
                                ? Colors.black87
                                : Colors.white70,
                            size: 33,
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
