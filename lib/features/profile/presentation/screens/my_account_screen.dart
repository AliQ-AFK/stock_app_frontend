import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/core/constants/app_colors.dart';
import 'package:stock_app_frontend/core/models/user.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';
import 'package:stock_app_frontend/core/services/payment_service.dart';
import 'package:stock_app_frontend/features/premium/presentation/screens/alpha_pro_screen.dart';
import 'package:stock_app_frontend/features/premium/presentation/widgets/pro_badge.dart';
import 'package:stock_app_frontend/features/authentication/presentation/screens/landing_screen.dart';
import 'package:stock_app_frontend/features/notifications/presentation/screens/notification_screen.dart';

class MyAccountScreen extends StatefulWidget {
  final User user;

  const MyAccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isPro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProStatus();
  }

  void _checkProStatus() async {
    bool proStatus = await PaymentService.getProStatus(widget.user.userId);
    setState(() {
      _isPro = proStatus;
      _isLoading = false;
    });
  }

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
            if (_isPro) ...[SizedBox(width: 8), ProBanner(text: 'PRO')],
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
                size: 28,
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
          // Profile Picture with Pro Badge and Edit Icon
          Stack(
            children: [
              ProProfilePicture(
                imageUrl: 'assets/images/profilepic.jpg',
                size: 120,
                isPro: _isPro,
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
            widget.user.username,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.getText(brightness),
            ),
          ),

          SizedBox(height: 8),

          // Email
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getText(brightness).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBanner(Brightness brightness, bool isLightMode) {
    if (_isPro) {
      // Show Pro Status
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.getGreen(brightness).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getGreen(brightness), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.star, color: AppColors.getGreen(brightness), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AlphaWave Pro Active',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getText(brightness),
                    ),
                  ),
                  Text(
                    'Enjoying all premium features',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getText(brightness).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.getGreen(brightness),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlphaPro(user: widget.user),
                    ),
                  );
                },
                child: Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getBG(brightness),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show Upgrade Banner
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
                  fontSize: 20,
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
                    MaterialPageRoute(
                      builder: (context) => AlphaPro(user: widget.user),
                    ),
                  );
                },
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    fontSize: 16,
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
            Text('User ID: ${widget.user.userId}'),
            SizedBox(height: 8),
            Text('Username: ${widget.user.username}'),
            SizedBox(height: 8),
            Text('Email: ${widget.user.email}'),
            SizedBox(height: 8),
            Text(
              'Account Created: ${widget.user.createdAt.toLocal().toString().split(' ')[0]}',
            ),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = themeProvider.brightness;
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
                      final themeProvider = Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      );
                      final brightness = themeProvider.brightness;
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
                          backgroundColor: AppColors.getRed(brightness),
                        ),
                      );
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: canDelete
                    ? AppColors.getRed(brightness)
                    : AppColors.getText(brightness).withOpacity(0.5),
              ),
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
