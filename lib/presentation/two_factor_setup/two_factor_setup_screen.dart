import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/two_factor_auth_service.dart';

/// Two-Factor Authentication Setup Screen
/// Allows users to enable TOTP-based 2FA using authenticator apps
class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  String _secret = '';
  String _qrData = '';
  List<String> _backupCodes = [];
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _setupComplete = false;
  final _verificationController = TextEditingController();
  String? _errorMessage;

  // Mock user email - in production, get from auth service
  final String _userEmail = 'user@tokenv.com';

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  /// Generate TOTP secret and QR code data
  Future<void> _generateSecret() async {
    setState(() => _isLoading = true);

    try {
      final secret = TwoFactorAuthService.generateSecret();
      final qrData =
          TwoFactorAuthService.getAuthenticatorUri(secret, _userEmail);
      final backupCodes = await TwoFactorAuthService.generateBackupCodes();

      setState(() {
        _secret = secret;
        _qrData = qrData;
        _backupCodes = backupCodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate 2FA setup. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Verify TOTP code and complete setup
  Future<void> _verifyAndComplete() async {
    final code = _verificationController.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final isValid = TwoFactorAuthService.verifyTOTPCode(_secret, code);

      if (isValid) {
        await TwoFactorAuthService.saveSecret(_secret);

        setState(() {
          _setupComplete = true;
          _isVerifying = false;
        });

        if (mounted) {
          HapticFeedback.mediumImpact();
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
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

  /// Copy secret key to clipboard
  void _copySecret() {
    Clipboard.setData(ClipboardData(text: _secret));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret key copied to clipboard')),
    );
  }

  /// Copy backup codes to clipboard
  void _copyBackupCodes() {
    final codes = _backupCodes.join('\n');
    Clipboard.setData(ClipboardData(text: codes));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup codes copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Two-Factor Authentication',
        variant: CustomAppBarVariant.standard,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _setupComplete
              ? _buildSetupComplete(theme)
              : _buildSetupSteps(theme),
    );
  }

  /// Build setup steps UI
  Widget _buildSetupSteps(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Security badge
          _buildSecurityBadge(theme),

          SizedBox(height: 4.h),

          // Step 1: Scan QR code
          _buildStepCard(
            theme,
            step: 1,
            title: 'Scan QR Code',
            description:
                'Open your authenticator app (Google Authenticator, Authy, etc.) and scan this QR code:',
            content: _buildQRCode(theme),
          ),

          SizedBox(height: 3.h),

          // Manual entry option
          _buildManualEntry(theme),

          SizedBox(height: 3.h),

          // Step 2: Verify code
          _buildStepCard(
            theme,
            step: 2,
            title: 'Verify Code',
            description: 'Enter the 6-digit code from your authenticator app:',
            content: _buildVerificationInput(theme),
          ),

          if (_errorMessage != null) ...[
            SizedBox(height: 2.h),
            _buildErrorMessage(theme),
          ],

          SizedBox(height: 3.h),

          // Verify button
          _buildVerifyButton(theme),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  /// Build security badge
  Widget _buildSecurityBadge(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'security',
              size: 24,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhanced Security',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Add an extra layer of protection to your account',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build step card
  Widget _buildStepCard(
    ThemeData theme, {
    required int step,
    required String title,
    required String description,
    required Widget content,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          content,
        ],
      ),
    );
  }

  /// Build QR code
  Widget _buildQRCode(ThemeData theme) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: PrettyQrView.data(
          data: _qrData,
          decoration: const PrettyQrDecoration(
            shape: PrettyQrSmoothSymbol(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// Build manual entry option
  Widget _buildManualEntry(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Can\'t scan? Enter manually:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _secret,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: _copySecret,
                icon: const CustomIconWidget(
                  iconName: 'content_copy',
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build verification input
  Widget _buildVerificationInput(ThemeData theme) {
    return TextField(
      controller: _verificationController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      enabled: !_isVerifying,
      decoration: InputDecoration(
        hintText: 'Enter 6-digit code',
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
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
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

  /// Build verify button
  Widget _buildVerifyButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isVerifying ? null : _verifyAndComplete,
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
              'Verify & Enable 2FA',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Build setup complete UI
  Widget _buildSetupComplete(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),

          // Success icon
          Center(
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Success message
          Text(
            '2FA Enabled Successfully!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Your account is now protected with two-factor authentication.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Backup codes section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      size: 24,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Save Your Backup Codes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Store these codes safely. You can use them to access your account if you lose your authenticator device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _backupCodes.map((code) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: Text(
                          code,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 2.h),
                OutlinedButton.icon(
                  onPressed: _copyBackupCodes,
                  icon: const CustomIconWidget(
                    iconName: 'content_copy',
                    size: 20,
                  ),
                  label: const Text('Copy Backup Codes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Done button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              elevation: 0,
            ),
            child: Text(
              'Done',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
