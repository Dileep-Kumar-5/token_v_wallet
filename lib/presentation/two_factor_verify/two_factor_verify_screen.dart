import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/two_factor_auth_service.dart';

/// Two-Factor Authentication Verification Screen
/// Verifies TOTP code during login
class TwoFactorVerifyScreen extends StatefulWidget {
  const TwoFactorVerifyScreen({super.key});

  @override
  State<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;
  bool _useBackupCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Verify TOTP code
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a code');
      return;
    }

    if (!_useBackupCode && code.length != 6) {
      setState(() => _errorMessage = 'Code must be 6 digits');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      bool isValid = false;

      if (_useBackupCode) {
        isValid = await TwoFactorAuthService.verifyBackupCode(code);
      } else {
        final secret = await TwoFactorAuthService.getSecret();
        if (secret != null) {
          isValid = TwoFactorAuthService.verifyTOTPCode(secret, code);
        }
      }

      if (isValid) {
        if (mounted) {
          HapticFeedback.mediumImpact();
          Navigator.pushReplacementNamed(context, '/wallet-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = _useBackupCode
              ? 'Invalid backup code or already used'
              : 'Invalid code. Please try again.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isVerifying = false;
      });
    }
  }

  /// Toggle backup code mode
  void _toggleBackupCode() {
    setState(() {
      _useBackupCode = !_useBackupCode;
      _codeController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Verify Code',
        variant: CustomAppBarVariant.standard,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),

              // Security icon
              Center(
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'verified_user',
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Title
              Text(
                _useBackupCode
                    ? 'Enter Backup Code'
                    : 'Enter Authenticator Code',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                _useBackupCode
                    ? 'Enter one of your backup codes to access your account'
                    : 'Open your authenticator app and enter the 6-digit code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Code input
              TextField(
                controller: _codeController,
                keyboardType:
                    _useBackupCode ? TextInputType.text : TextInputType.number,
                maxLength: _useBackupCode ? 9 : 6,
                enabled: !_isVerifying,
                decoration: InputDecoration(
                  hintText: _useBackupCode ? 'XXXX-XXXX' : 'XXXXXX',
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                inputFormatters: _useBackupCode
                    ? null
                    : [FilteringTextInputFormatter.digitsOnly],
              ),

              if (_errorMessage != null) ...[
                SizedBox(height: 2.h),
                Container(
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
                ),
              ],

              SizedBox(height: 3.h),

              // Verify button
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  elevation: 0,
                ),
                child: _isVerifying
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Verify',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              SizedBox(height: 3.h),

              // Toggle backup code
              TextButton(
                onPressed: _isVerifying ? null : _toggleBackupCode,
                child: Text(
                  _useBackupCode
                      ? 'Use authenticator code instead'
                      : 'Use backup code instead',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Help text
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'help_outline',
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Need help?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• Codes refresh every 30 seconds\n'
                      '• Make sure your device time is correct\n'
                      '• Use backup codes if you lost your device',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
