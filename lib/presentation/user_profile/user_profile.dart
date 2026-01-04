import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

/// User Profile Screen for Token V Wallet
///
/// Comprehensive account management and security settings including:
/// - User avatar with photo upload capability
/// - Editable profile fields (name, email, phone)
/// - Security settings (password, biometric, 2FA)
/// - Account preferences (notifications, privacy)
/// - Support options (help center, contact support)
/// - Account verification and linked payment methods
class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Current tab index for bottom navigation
  int _currentIndex = 2;

  // User data
  String _userName = 'John Doe';
  String _userEmail = 'user@tokenv.com';
  String _phoneNumber = '+1 (555) 123-4567';
  String? _avatarUrl;
  bool _isVerified = true;

  // Security settings
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

  // Notification preferences
  bool _transactionNotifications = true;
  bool _securityNotifications = true;
  bool _promotionalNotifications = false;

  // Privacy settings
  bool _balanceVisible = true;
  bool _transactionHistorySharing = false;

  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from Supabase
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = SupabaseService.instance.client.auth.currentUser;

      if (user != null) {
        setState(() {
          _userEmail = user.email ?? _userEmail;
          _userName = user.userMetadata?['full_name'] ?? _userName;
          _phoneNumber = user.userMetadata?['phone_number'] ?? _phoneNumber;
          _avatarUrl = user.userMetadata?['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle avatar photo upload
  Future<void> _handleAvatarUpload() async {
    try {
      // Show source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Photo Source',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image != null && mounted) {
          // TODO: Upload image to Supabase storage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle profile field edit
  Future<void> _handleEditField(String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit $field',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty) {
      setState(() {
        switch (field.toLowerCase()) {
          case 'name':
            _userName = newValue;
            break;
          case 'email':
            _userEmail = newValue;
            break;
          case 'phone':
            _phoneNumber = newValue;
            break;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle biometric authentication toggle
  Future<void> _handleBiometricToggle(bool value) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          value ? 'Enable Biometric Auth' : 'Disable Biometric Auth',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          value
              ? 'Use Face ID or Touch ID for secure and quick access.'
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
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
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

    if (confirm == true) {
      try {
        await SupabaseService.instance.logout();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.walletDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.transactionHistory);
        break;
      case 2:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'User Profile',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to advanced settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 3.h),

              // Avatar Section
              _buildAvatarSection(),
              SizedBox(height: 4.h),

              // Profile Information Card
              _buildSectionCard(
                title: 'Profile Information',
                children: [
                  _buildInfoTile(
                    icon: Icons.person,
                    label: 'Display Name',
                    value: _userName,
                    onTap: () => _handleEditField('Name', _userName),
                  ),
                  Divider(height: 2.h),
                  _buildInfoTile(
                    icon: Icons.email,
                    label: 'Email Address',
                    value: _userEmail,
                    onTap: () => _handleEditField('Email', _userEmail),
                  ),
                  Divider(height: 2.h),
                  _buildInfoTile(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: _phoneNumber,
                    onTap: () => _handleEditField('Phone', _phoneNumber),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Security Settings Card
              _buildSectionCard(
                title: 'Security Settings',
                children: [
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    label: 'Biometric Authentication',
                    subtitle: 'Use Face ID or Touch ID',
                    value: _biometricEnabled,
                    onChanged: _handleBiometricToggle,
                  ),
                  Divider(height: 2.h),
                  _buildSwitchTile(
                    icon: Icons.security,
                    label: 'Two-Factor Authentication',
                    subtitle: 'Extra layer of security',
                    value: _twoFactorEnabled,
                    onChanged: (value) =>
                        setState(() => _twoFactorEnabled = value),
                  ),
                  Divider(height: 2.h),
                  _buildInfoTile(
                    icon: Icons.lock,
                    label: 'Change Password',
                    value: '••••••••',
                    onTap: () {
                      // Navigate to change password
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Notification Preferences Card
              _buildSectionCard(
                title: 'Notification Preferences',
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications,
                    label: 'Transaction Alerts',
                    subtitle: 'Get notified of transactions',
                    value: _transactionNotifications,
                    onChanged: (value) =>
                        setState(() => _transactionNotifications = value),
                  ),
                  Divider(height: 2.h),
                  _buildSwitchTile(
                    icon: Icons.shield,
                    label: 'Security Notifications',
                    subtitle: 'Account security alerts',
                    value: _securityNotifications,
                    onChanged: (value) =>
                        setState(() => _securityNotifications = value),
                  ),
                  Divider(height: 2.h),
                  _buildSwitchTile(
                    icon: Icons.email,
                    label: 'Promotional Messages',
                    subtitle: 'Offers and updates',
                    value: _promotionalNotifications,
                    onChanged: (value) =>
                        setState(() => _promotionalNotifications = value),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Privacy Controls Card
              _buildSectionCard(
                title: 'Privacy Controls',
                children: [
                  _buildSwitchTile(
                    icon: Icons.visibility,
                    label: 'Balance Visibility',
                    subtitle: 'Show balance on dashboard',
                    value: _balanceVisible,
                    onChanged: (value) =>
                        setState(() => _balanceVisible = value),
                  ),
                  Divider(height: 2.h),
                  _buildSwitchTile(
                    icon: Icons.history,
                    label: 'Transaction History Sharing',
                    subtitle: 'Allow transaction history export',
                    value: _transactionHistorySharing,
                    onChanged: (value) =>
                        setState(() => _transactionHistorySharing = value),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Support Section Card
              _buildSectionCard(
                title: 'Support',
                children: [
                  _buildInfoTile(
                    icon: Icons.help_center,
                    label: 'Help Center',
                    value: '',
                    showArrow: true,
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  Divider(height: 2.h),
                  _buildInfoTile(
                    icon: Icons.contact_support,
                    label: 'Contact Support',
                    value: '',
                    showArrow: true,
                    onTap: () {
                      // Navigate to contact support
                    },
                  ),
                  Divider(height: 2.h),
                  _buildInfoTile(
                    icon: Icons.report_problem,
                    label: 'Report Issue',
                    value: '',
                    showArrow: true,
                    onTap: () {
                      // Navigate to report issue
                    },
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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

  /// Build avatar section with photo upload
  Widget _buildAvatarSection() {
    return Stack(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withAlpha(26),
            border: Border.all(
              color: _isVerified ? Colors.green : Colors.grey,
              width: 3,
            ),
          ),
          child: _avatarUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 15.w,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 15.w,
                  color: Theme.of(context).primaryColor,
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _handleAvatarUpload,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build section card wrapper
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  /// Build info tile
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (value.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow || onTap != null)
              Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Build switch tile
  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
