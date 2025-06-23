import 'package:flutter/material.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUp2 extends StatefulWidget {
  @override
  _SignUp2state createState() => _SignUp2state();
}

class _SignUp2state extends State<SignUp2> {
  String? selectedGender;

  ///Choices for dropbox
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

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

                  ///Name section
                  Text(
                    'Full Name',
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
                      hintText: 'Type your Full name',
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

                  ///Phone section
                  Text(
                    'Phone Number',
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
                        Icons.phone,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      hintText: 'Type your Phone number ',
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

                  /// Gender Dropdown
                  Row(
                    children: [
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: AppColors.getBG(brightness),
                          isExpanded: false,
                          value: selectedGender,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.getText(
                              brightness,
                            ).withOpacity(0.5),
                          ),
                          hint: const Text(
                            'Select Gender',
                            style: TextStyle(color: Colors.grey),
                          ),
                          items: genderOptions.map((gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(
                                gender,
                                style: TextStyle(
                                  color: AppColors.getText(brightness),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  /// Date of Birth
                  const SizedBox(height: 24),
                  SizedBox(height: 20),
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.calendar_month_sharp,
                        color: AppColors.getText(brightness).withOpacity(0.5),
                      ),
                      hintText: 'DD/MM/YYYY',
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
                  SizedBox(height: 40),

                  ///sign up Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save data+ navigate to Dashboard
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
                        'Sign up',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
