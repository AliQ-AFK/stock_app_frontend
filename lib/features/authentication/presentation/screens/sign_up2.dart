import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/user_service.dart';
import 'package:stock_app_frontend/features/dashboard/presentation/screens/main_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUp2 extends StatefulWidget {
  final String email;
  final String password;

  const SignUp2({Key? key, required this.email, required this.password})
    : super(key: key);

  @override
  _SignUp2state createState() => _SignUp2state();
}

class _SignUp2state extends State<SignUp2> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? selectedGender;
  DateTime? selectedDate;
  String selectedCountryCode = '+1';
  bool _isLoading = false;

  ///Choices for dropbox
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(Duration(days: 18 * 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _isAtLeast18() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    final age = now.year - selectedDate!.year;
    if (now.month < selectedDate!.month ||
        (now.month == selectedDate!.month && now.day < selectedDate!.day)) {
      return age - 1 >= 18;
    }
    return age >= 18;
  }

  Future<void> _completeSignUp() async {
    // Validate all fields
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your full name')));
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your phone number')));
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select your gender')));
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    if (!_isAtLeast18()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be at least 18 years old to sign up')),
      );
      return;
    }

    // Check if email already exists
    if (UserService.emailExists(widget.email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An account with this email already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user object
      final newUser = User(
        userID: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: widget.email,
        username: widget.email.split('@')[0], // Use email prefix as username
        password: widget.password,
        phoneNumber: '$selectedCountryCode ${_phoneController.text}',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Register user using UserService
      await UserService.register(newUser);

      // Navigate to main screen (portfolio)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(user: newUser)),
        (route) => false, // Remove all previous routes
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to AlphaWave, ${newUser.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        elevation: 0,
        title: Text(
          'Sign up',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: isLightMode ? Colors.black87 : Colors.white70,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.getBG(brightness),
        child: SingleChildScrollView(
          child: Padding(
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
                  controller: _nameController,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Country code picker
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isLightMode
                                ? Colors.black87
                                : Colors.white70,
                          ),
                        ),
                      ),
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            selectedCountryCode = country.dialCode!;
                          });
                        },
                        initialSelection: 'US',
                        favorite: ['+1', 'US'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: TextStyle(
                          color: AppColors.getText(brightness),
                          fontSize: 16,
                        ),
                        dialogTextStyle: TextStyle(
                          color: AppColors.getText(brightness),
                        ),
                        searchStyle: TextStyle(
                          color: AppColors.getText(brightness),
                        ),
                        backgroundColor: AppColors.getBG(brightness),
                        barrierColor: Colors.black54,
                        boxDecoration: BoxDecoration(
                          color: AppColors.getBG(brightness),
                        ),
                        showDropDownButton: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Phone number input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppColors.getText(
                              brightness,
                            ).withOpacity(0.5),
                          ),
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.getText(
                              brightness,
                            ).withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isLightMode
                                  ? Colors.black87
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

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
                          color: AppColors.getText(brightness).withOpacity(0.5),
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
                SizedBox(height: 30),

                /// Date of Birth with Date Picker
                Text(
                  'Date of Birth',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    color: isLightMode ? Colors.black87 : Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isLightMode ? Colors.black87 : Colors.white70,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_sharp,
                          color: AppColors.getText(brightness).withOpacity(0.5),
                        ),
                        SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select your date of birth',
                          style: TextStyle(
                            fontSize: selectedDate != null ? 18 : 20,
                            fontWeight: FontWeight.w400,
                            color: selectedDate != null
                                ? (isLightMode
                                      ? Colors.black87
                                      : Colors.white70)
                                : AppColors.getText(
                                    brightness,
                                  ).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),

                ///Sign up Button
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSignUp,
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
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLightMode ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
