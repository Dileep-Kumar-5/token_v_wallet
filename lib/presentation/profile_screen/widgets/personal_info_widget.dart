import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Personal Information Widget
///
/// Displays user's personal information in a card layout
class PersonalInfoWidget extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String memberSince;
  final String accountStatus;

  const PersonalInfoWidget({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.memberSince,
    required this.accountStatus,
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
          Text(
            'Personal Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          // Full name
          _buildInfoRow(
            context,
            icon: 'person',
            label: 'Full Name',
            value: name,
          ),

          SizedBox(height: 1.5.h),

          // Email
          _buildInfoRow(
            context,
            icon: 'email',
            label: 'Email Address',
            value: email,
          ),

          SizedBox(height: 1.5.h),

          // Phone
          _buildInfoRow(
            context,
            icon: 'phone',
            label: 'Phone Number',
            value: phone,
          ),

          SizedBox(height: 1.5.h),

          // Member since
          _buildInfoRow(
            context,
            icon: 'calendar_today',
            label: 'Member Since',
            value: memberSince,
          ),

          SizedBox(height: 1.5.h),

          // Account status
          _buildInfoRow(
            context,
            icon: 'check_circle',
            label: 'Account Status',
            value: accountStatus.toUpperCase(),
            valueColor: accountStatus == 'active'
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
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

        // Label and value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
