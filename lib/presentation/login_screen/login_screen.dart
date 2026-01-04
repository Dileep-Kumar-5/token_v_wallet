import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/two_factor_auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/login_button_widget.dart';
import './widgets/password_input_widget.dart';

/// Login Screen for Token V Wallet
///
/// Provides secure user authentication with:
/// - Email/password login with validation
/// - Biometric authentication (Face ID/Touch ID/Fingerprint)
/// - Forgot password functionality
/// - Account creation navigation
/// - Session management
/// - Security indicators
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State management
  bool _isLoading = false;
  bool _biometricEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric check - in production, use local_auth package
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _biometricEnabled = true;
      });
    }
  }

  /// Handle login submission
  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call - in production, call actual authentication API
      await Future.delayed(const Duration(seconds: 2));

      // Mock credentials for testing
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Validate credentials
      if (email == 'user@tokenv.com' && password == 'User@123') {
        // Check if 2FA is enabled
        final is2FAEnabled = await TwoFactorAuthService.is2FAEnabled();

        if (mounted) {
          HapticFeedback.mediumImpact();

          if (is2FAEnabled) {
            // Navigate to 2FA verification
            Navigator.pushNamed(context, '/two-factor-verify');
          } else {
            // Navigate directly to dashboard
            Navigator.pushReplacementNamed(context, '/wallet-dashboard');
          }
        }
      } else if (email == 'frozen@tokenv.com' && password == 'Frozen@123') {
        // Account frozen scenario
        setState(() {
          _errorMessage =
              'Your account has been frozen by an administrator. Please contact support.';
        });
      } else {
        // Invalid credentials
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
      }
    } catch (e) {
      // Network or other error
      setState(() {
        _errorMessage =
            'Unable to connect. Please check your internet connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle biometric authentication
  Future<void> _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate biometric authentication - in production, use local_auth package
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Success - navigate to wallet dashboard
        HapticFeedback.mediumImpact();
        Navigator.pushReplacementNamed(context, '/wallet-dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Biometric authentication failed. Please try again or use password.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle forgot password
  void _handleForgotPassword() {
    // Show forgot password dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Password reset functionality will be available soon. Please contact support for assistance.',
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

  /// Handle create account navigation
  void _handleCreateAccount() {
    Navigator.pushNamed(context, '/user-registration');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Login',
        variant: CustomAppBarVariant.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.h),

                    // Logo and security badge
                    _buildLogoSection(theme),

                    SizedBox(height: 6.h),

                    // Email input
                    EmailInputWidget(
                      controller: _emailController,
                      enabled: !_isLoading,
                    ),

                    SizedBox(height: 2.h),

                    // Password input
                    PasswordInputWidget(
                      controller: _passwordController,
                      enabled: !_isLoading,
                    ),

                    SizedBox(height: 1.h),

                    // Forgot password link
                    _buildForgotPasswordLink(theme),

                    SizedBox(height: 3.h),

                    // Error message
                    if (_errorMessage != null) ...[
                      _buildErrorMessage(theme),
                      SizedBox(height: 2.h),
                    ],

                    // Login button
                    LoginButtonWidget(
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      enabled: !_isLoading,
                    ),

                    SizedBox(height: 3.h),

                    // Biometric authentication
                    if (_biometricEnabled) ...[
                      BiometricAuthWidget(
                        onPressed: _handleBiometricAuth,
                        enabled: !_isLoading,
                      ),
                      SizedBox(height: 3.h),
                    ],

                    // Create account link
                    _buildCreateAccountLink(theme),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo section with security badge
  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'TV',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App name
        Text(
          'Token V Wallet',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 1.h),

        // Security badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'verified_user',
                size: 16,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 1.w),
              Text(
                'Secure Login',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build forgot password link
  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _handleForgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            size: 20,
            color: theme.colorScheme.error,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build create account link
  Widget _buildCreateAccountLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New user? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleCreateAccount,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Create Account',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
