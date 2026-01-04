import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Preferences Widget
///
/// Displays app preferences including notifications and email settings
class PreferencesWidget extends StatelessWidget {
  final bool notificationsEnabled;
  final bool transactionAlertsEnabled;
  final bool marketingEmailsEnabled;
  final Function(bool) onNotificationsToggle;
  final Function(bool) onTransactionAlertsToggle;
  final Function(bool) onMarketingEmailsToggle;

  const PreferencesWidget({
    super.key,
    required this.notificationsEnabled,
    required this.transactionAlertsEnabled,
    required this.marketingEmailsEnabled,
    required this.onNotificationsToggle,
    required this.onTransactionAlertsToggle,
    required this.onMarketingEmailsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              CustomIconWidget(
                iconName: 'settings',
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Preferences',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Push notifications
          _buildToggleRow(
            context,
            icon: 'notifications',
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: notificationsEnabled,
            onChanged: onNotificationsToggle,
          ),

          SizedBox(height: 1.5.h),

          Divider(height: 1, color: theme.dividerColor),

          SizedBox(height: 1.5.h),

          // Transaction alerts
          _buildToggleRow(
            context,
            icon: 'receipt_long',
            title: 'Transaction Alerts',
            subtitle: 'Get notified for all transactions',
            value: transactionAlertsEnabled,
            onChanged: onTransactionAlertsToggle,
          ),

          SizedBox(height: 1.5.h),

          Divider(height: 1, color: theme.dividerColor),

          SizedBox(height: 1.5.h),

          // Marketing emails
          _buildToggleRow(
            context,
            icon: 'mail',
            title: 'Marketing Emails',
            subtitle: 'Receive promotional content',
            value: marketingEmailsEnabled,
            onChanged: onMarketingEmailsToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Icon
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: CustomIconWidget(
            iconName: icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),

        SizedBox(width: 3.w),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Toggle switch
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
