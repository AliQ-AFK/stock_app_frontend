import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/features/premium/presentation/screens/alpha_pro_screen.dart';
import 'package:stock_app_frontend/features/authentication/presentation/screens/landing_screen.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

class MyAccountScreen extends StatefulWidget {
  final User user;

  const MyAccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = themeProvider.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBG(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.getBG(brightness),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'My Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),
            const Spacer(),
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
                size: 24,
              ),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),

            // Profile Section
            _buildProfileSection(brightness, isLightMode),

            SizedBox(height: 30),

            // AlphaWave Pro Banner
            _buildProBanner(brightness, isLightMode),

            SizedBox(height: 30),

            // Menu Items
            _buildMenuItems(brightness, isLightMode),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(Brightness brightness, bool isLightMode) {
    return Container(
      child: Column(
        children: [
          // Profile Picture with Edit Icon
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.getText(brightness).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.getGreyBG(brightness),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.getText(brightness).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.getText(brightness),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.getBG(brightness),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // User Name
          Text(
            widget.user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.getText(brightness),
            ),
          ),

          SizedBox(height: 8),

          // Email and Phone
          Text(
            '${widget.user.email} | ${widget.user.phoneNumber}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBanner(Brightness brightness, bool isLightMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.getGreyBG(brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Get AlphaWave Pro!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getText(brightness),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getText(brightness),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlphaPro()),
                );
              },
              child: Text(
                'info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getBG(brightness),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(Brightness brightness, bool isLightMode) {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Personal info',
        'onTap': () {
          _showPersonalInfoDialog();
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'onTap': () {
          _showLogoutDialog();
        },
      },
      {
        'icon': Icons.attach_money,
        'title': 'Currency',
        'onTap': () {
          _showCurrencyDialog();
        },
      },
      {
        'icon': Icons.wb_sunny_outlined,
        'title': 'Theme',
        'onTap': () {
          _showThemeDialog();
        },
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'onTap': () {
          _showHelpDialog();
        },
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Terms of Service',
        'onTap': () {
          _showTermsDialog();
        },
      },
      {
        'icon': Icons.delete_outline,
        'title': 'Delete your account',
        'onTap': () {
          _showDeleteAccountDialog();
        },
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getGreyBG(brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: AppColors.getText(brightness),
                size: 24,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.getText(brightness),
              ),
            ),
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Personal Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.user.name}'),
            SizedBox(height: 8),
            Text('Email: ${widget.user.email}'),
            SizedBox(height: 8),
            Text('Phone: ${widget.user.phoneNumber}'),
            SizedBox(height: 8),
            Text('Username: ${widget.user.username}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LandingScreen()),
                (route) => false,
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Currency Settings'),
        content: Text('Currency selection feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppTheme>(
              title: Text('Light'),
              value: AppTheme.light,
              groupValue: themeProvider.currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppTheme>(
              title: Text('Dark'),
              value: AppTheme.dark,
              groupValue: themeProvider.currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppTheme>(
              title: Text('System'),
              value: AppTheme.system,
              groupValue: themeProvider.currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 16),
            Text('📧 support@alphawave.com'),
            SizedBox(height: 8),
            Text('📞 +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('🕒 Mon-Fri 9AM-6PM EST'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'AlphaWave Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using AlphaWave, you agree to these terms.\n\n'
            '2. Service Description\n'
            'AlphaWave is a stock trading simulation app for educational purposes.\n\n'
            '3. User Responsibilities\n'
            'Users must provide accurate information and use the service responsibly.\n\n'
            '4. Privacy Policy\n'
            'We protect your privacy and handle data according to our privacy policy.\n\n'
            '5. Disclaimer\n'
            'This is an educational app. No real money or trades are involved.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final TextEditingController deleteController = TextEditingController();
    bool canDelete = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'To confirm deletion, please type "DELETE" below:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: deleteController,
                decoration: InputDecoration(
                  hintText: 'Type DELETE here',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    canDelete = value.trim().toUpperCase() == 'DELETE';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                deleteController.dispose();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: canDelete
                  ? () {
                      deleteController.dispose();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandingScreen(),
                        ),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account deleted successfully'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: canDelete ? Colors.red : Colors.grey,
              ),
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
