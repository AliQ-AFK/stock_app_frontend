import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'sign_up2.dart';

class SignUp1 extends StatefulWidget {
  @override
  _SignUp1state createState() => _SignUp1state();
}

class _SignUp1state extends State<SignUp1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.getBG(brightness),
        title: Text(
          'Sign up',
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
                    controller: _emailController,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
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
                    controller: _passwordController,
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
                  SizedBox(height: 20),

                  ///Confirm Password section
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
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
                      hintText: 'Confirm your Password',
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

                  ///Next Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate form data
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }

                        if (!_emailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a valid email'),
                            ),
                          );
                          return;
                        }

                        if (_passwordController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Password must be at least 6 characters',
                              ),
                            ),
                          );
                          return;
                        }

                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }

                        // Navigate to next screen with data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUp2(
                              email: _emailController.text,
                              password: _passwordController.text,
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
                        'Next',
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
                      'Or sign up using',
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
                            onTap: () {},
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: Image.asset(
                                    'assets/icons/google_login.png',
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
