import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/profile_header_widget.dart';
import './widgets/personal_info_widget.dart';
import './widgets/security_settings_widget.dart';
import './widgets/preferences_widget.dart';
import './widgets/account_actions_widget.dart';
import '../../services/supabase_service.dart';

/// Profile Screen for Token V Wallet
///
/// Displays user account information and settings including:
/// - Profile header with avatar and basic info
/// - Personal information section
/// - Security settings with biometric preferences
/// - App preferences and settings
/// - Account management actions
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Current tab index for bottom navigation
  int _currentIndex = 2;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'email': 'user@tokenv.com',
    'phone': '+1 (555) 123-4567',
    'memberSince': 'January 2025',
    'accountStatus': 'active',
    'verificationLevel': 'verified',
    'avatar':
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
  };

  // Security settings
  bool _biometricEnabled = true;
  bool _faceIdEnabled = true;
  bool _touchIdEnabled = false;
  bool _twoFactorEnabled = false;
  bool _notificationsEnabled = true;
  bool _transactionAlertsEnabled = true;
  bool _marketingEmailsEnabled = false;

  // Add local auth instance
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Handle biometric toggle
  Future<void> _handleBiometricToggle(bool value) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          value
              ? 'Enable Biometric Authentication'
              : 'Disable Biometric Authentication',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          value
              ? 'Allow biometric authentication for quick and secure access to your wallet.'
              : 'You will need to use your password for authentication.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();
      setState(() => _biometricEnabled = value);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Biometric authentication enabled'
                  : 'Biometric authentication disabled',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle Face ID toggle
  void _handleFaceIdToggle(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _faceIdEnabled = value);
  }

  /// Handle Touch ID toggle
  void _handleTouchIdToggle(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _touchIdEnabled = value);
  }

  /// Handle two-factor authentication toggle
  Future<void> _handleTwoFactorToggle(bool value) async {
    if (value) {
      // Show setup dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Setup Two-Factor Authentication',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Two-factor authentication adds an extra layer of security. Setup will be available soon.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _twoFactorEnabled = value);
    }
  }

  /// Handle notifications toggle
  void _handleNotificationsToggle(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _notificationsEnabled = value);
  }

  /// Handle transaction alerts toggle
  void _handleTransactionAlertsToggle(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _transactionAlertsEnabled = value);
  }

  /// Handle marketing emails toggle
  void _handleMarketingEmailsToggle(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _marketingEmailsEnabled = value);
  }

  /// Handle edit profile
  void _handleEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Profile editing feature will be available soon.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle change password
  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Password change feature will be available soon.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle logout with biometric confirmation
  Future<void> _handleLogout() async {
    try {
      // Step 1: Check if biometric authentication is available
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      // Step 2: If biometric is available and enabled, request authentication
      if (canAuthenticate && _biometricEnabled) {
        try {
          final bool didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Authenticate to logout from your account',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
            ),
          );

          // If biometric authentication failed, cancel logout
          if (!didAuthenticate) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication required to logout'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }
        } catch (e) {
          // If biometric fails, show error but don't proceed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Authentication error: ${e.toString()}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      // Step 3: Show confirmation dialog after successful biometric auth
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Logout',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout from your account? Your session will be cleared.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      // Step 4: If user confirmed, perform logout
      if (confirm == true) {
        HapticFeedback.mediumImpact();

        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Step 5: Clear session from Supabase
        await SupabaseService.instance.logout();

        // Close loading indicator
        if (mounted) {
          Navigator.pop(context);
        }

        // Step 6: Navigate to login screen and clear navigation stack
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login-screen',
            (route) => false,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully logged out'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors during logout
      if (mounted) {
        // Close loading indicator if it's showing
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle delete account
  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show final confirmation
      final finalConfirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Final Confirmation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          content: Text(
            'Are you absolutely sure? This action is permanent and cannot be reversed.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Yes, Delete My Account'),
            ),
          ],
        ),
      );

      if (finalConfirm == true) {
        HapticFeedback.heavyImpact();
        // Navigate to login screen
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login-screen',
            (route) => false,
          );
        }
      }
    }
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    // Navigate to appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/wallet-dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/transaction-history');
        break;
      case 2:
        // Already on profile screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Profile',
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Profile header
              ProfileHeaderWidget(
                name: _userData['name'],
                email: _userData['email'],
                avatar: _userData['avatar'],
                verificationLevel: _userData['verificationLevel'],
                onEditPressed: _handleEditProfile,
              ),

              SizedBox(height: 3.h),

              // Personal information
              PersonalInfoWidget(
                name: _userData['name'],
                email: _userData['email'],
                phone: _userData['phone'],
                memberSince: _userData['memberSince'],
                accountStatus: _userData['accountStatus'],
              ),

              SizedBox(height: 2.h),

              // Security settings
              SecuritySettingsWidget(),

              SizedBox(height: 2.h),

              // Preferences
              PreferencesWidget(
                notificationsEnabled: _notificationsEnabled,
                transactionAlertsEnabled: _transactionAlertsEnabled,
                marketingEmailsEnabled: _marketingEmailsEnabled,
                onNotificationsToggle: _handleNotificationsToggle,
                onTransactionAlertsToggle: _handleTransactionAlertsToggle,
                onMarketingEmailsToggle: _handleMarketingEmailsToggle,
              ),

              SizedBox(height: 2.h),

              // Account actions
              AccountActionsWidget(
                onLogout: _handleLogout,
                onDeleteAccount: _handleDeleteAccount,
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
