import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/password_strength_indicator_widget.dart';
import './widgets/registration_form_widget.dart';

/// User Registration Screen
///
/// Enables new users to create secure wallet accounts with automated internal
/// wallet generation. Features include:
/// - Sequential input validation with real-time feedback
/// - Password strength indicator
/// - Terms & Privacy acceptance
/// - Biometric setup prompt after successful registration
/// - Auto-save form progress
class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  // Validation states
  bool _isFullNameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isPasswordValid = false;

  // Password strength (0-4)
  int _passwordStrength = 0;

  // Error messages
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _fullNameController.addListener(_validateFullName);
    _emailController.addListener(_validateEmail);
    _phoneController.addListener(_validatePhone);
    _passwordController.addListener(_validatePassword);
  }

  void _validateFullName() {
    setState(() {
      final name = _fullNameController.text.trim();
      if (name.isEmpty) {
        _isFullNameValid = false;
        _fullNameError = null;
      } else if (name.length < 2) {
        _isFullNameValid = false;
        _fullNameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        _isFullNameValid = false;
        _fullNameError = 'Name can only contain letters';
      } else {
        _isFullNameValid = true;
        _fullNameError = null;
      }
    });
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _isEmailValid = false;
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _isEmailValid = false;
        _emailError = 'Please enter a valid email address';
      } else {
        _isEmailValid = true;
        _emailError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _isPhoneValid = false;
        _phoneError = null;
      } else if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone)) {
        _isPhoneValid = false;
        _phoneError = 'Please enter a valid phone number';
      } else {
        _isPhoneValid = true;
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;

      if (password.isEmpty) {
        _isPasswordValid = false;
        _passwordError = null;
        _passwordStrength = 0;
        return;
      }

      // Calculate password strength
      int strength = 0;
      if (password.length >= 8) strength++;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
      if (RegExp(r'[a-z]').hasMatch(password)) strength++;
      if (RegExp(r'[0-9]').hasMatch(password)) strength++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

      _passwordStrength = strength;

      // Validation
      if (password.length < 8) {
        _isPasswordValid = false;
        _passwordError = 'Password must be at least 8 characters';
      } else if (strength < 3) {
        _isPasswordValid = false;
        _passwordError =
            'Password is too weak. Use uppercase, lowercase, and numbers';
      } else {
        _isPasswordValid = true;
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _isFullNameValid &&
        _isEmailValid &&
        _isPhoneValid &&
        _isPasswordValid &&
        _isTermsAccepted;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call for account creation and wallet generation
      await Future.delayed(const Duration(seconds: 2));

      // Check for duplicate email (simulated)
      if (_emailController.text.trim().toLowerCase() ==
          'existing@example.com') {
        if (mounted) {
          _showErrorDialog(
            'Email Already Exists',
            'This email is already registered. Would you like to login instead?',
            showLoginButton: true,
          );
        }
        return;
      }

      // Success - show celebration and navigate
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Registration Failed',
          'Unable to create account. Please check your connection and try again.',
          showRetryButton: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Account Created!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your wallet has been created successfully',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _promptBiometricSetup();
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _promptBiometricSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enable Biometric Login?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'fingerprint',
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Use Face ID/Touch ID or fingerprint to securely access your wallet',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/wallet-dashboard');
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In real implementation, this would trigger biometric enrollment
              Navigator.pushReplacementNamed(context, '/wallet-dashboard');
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(
    String title,
    String message, {
    bool showLoginButton = false,
    bool showRetryButton = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          if (showLoginButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: const Text('Go to Login'),
            ),
          if (showRetryButton)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRegistration();
              },
              child: const Text('Retry'),
            ),
          if (!showLoginButton && !showRetryButton)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms & Privacy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Terms of Service',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                'By creating an account, you agree to our terms of service and privacy policy. Your data will be securely stored and used only for wallet operations.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                'We protect your personal information and will never share it with third parties without your consent.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/login-screen'),
                      tooltip: 'Back to Login',
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Logo
                  Center(
                    child: Container(
                      width: 25.w,
                      height: 25.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'TV',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Title
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'Join Token V Wallet and start managing your credits securely',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 4.h),

                  // Registration Form
                  RegistrationFormWidget(
                    formKey: _formKey,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    fullNameFocusNode: _fullNameFocusNode,
                    emailFocusNode: _emailFocusNode,
                    phoneFocusNode: _phoneFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    isPasswordVisible: _isPasswordVisible,
                    isFullNameValid: _isFullNameValid,
                    isEmailValid: _isEmailValid,
                    isPhoneValid: _isPhoneValid,
                    isPasswordValid: _isPasswordValid,
                    fullNameError: _fullNameError,
                    emailError: _emailError,
                    phoneError: _phoneError,
                    passwordError: _passwordError,
                    onPasswordVisibilityToggle: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty)
                    PasswordStrengthIndicatorWidget(
                      strength: _passwordStrength,
                    ),

                  SizedBox(height: 3.h),

                  // Terms & Privacy Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isTermsAccepted,
                          onChanged: (value) {
                            setState(() => _isTermsAccepted = value ?? false);
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTermsDialog,
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Privacy Policy',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isLoading
                          ? _handleRegistration
                          : null,
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/login-screen'),
                        child: Text(
                          'Login',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
