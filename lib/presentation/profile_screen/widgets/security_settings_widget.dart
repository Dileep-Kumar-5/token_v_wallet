import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/two_factor_auth_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class SecuritySettingsWidget extends StatefulWidget {
  const SecuritySettingsWidget({super.key});

  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
  bool _is2FAEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _check2FAStatus();
  }

  Future<void> _check2FAStatus() async {
    final enabled = await TwoFactorAuthService.is2FAEnabled();
    setState(() {
      _is2FAEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggle2FA(bool value) async {
    if (value) {
      // Navigate to 2FA setup
      final result = await Navigator.pushNamed(context, '/two-factor-setup');
      if (result == true) {
        await _check2FAStatus();
      }
    } else {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable 2FA'),
          content: const Text(
            'Are you sure you want to disable two-factor authentication? '
            'This will make your account less secure.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await TwoFactorAuthService.disable2FA();
        await _check2FAStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildSecurityItem(
                theme,
                icon: 'lock',
                title: 'Change Password',
                subtitle: 'Last changed 30 days ago',
                onTap: () {
                  // Navigate to change password screen
                },
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _build2FAToggle(theme),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildSecurityItem(
                theme,
                icon: 'devices',
                title: 'Trusted Devices',
                subtitle: 'Manage your trusted devices',
                onTap: () {
                  Navigator.pushNamed(context, '/trusted-devices');
                },
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildSecurityItem(
                theme,
                icon: 'account_balance_wallet',
                title: 'Spending Limits',
                subtitle: 'Set daily and monthly limits',
                onTap: () {
                  Navigator.pushNamed(context, '/spending-limits');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2FAToggle(ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: 'verified_user',
          size: 24,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        'Two-Factor Authentication',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _is2FAEnabled ? 'Enabled' : 'Add extra security',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: _is2FAEnabled,
              onChanged: _toggle2FA,
            ),
    );
  }

  Widget _buildSecurityItem(
    ThemeData theme, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        size: 24,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
