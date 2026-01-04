import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile Header Widget
///
/// Displays user's profile picture, name, email, and verification status
class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String email;
  final String avatar;
  final String verificationLevel;
  final VoidCallback onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.email,
    required this.avatar,
    required this.verificationLevel,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
        children: [
          // Avatar and edit button
          Stack(
            children: [
              // Avatar
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    semanticLabel: 'Profile picture of $name',
                  ),
                ),
              ),

              // Verification badge
              if (verificationLevel == 'verified')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'verified',
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Name
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 0.5.h),

          // Email
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Edit profile button
          OutlinedButton.icon(
            onPressed: onEditPressed,
            icon: CustomIconWidget(
              iconName: 'edit',
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Edit Profile',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              side: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
