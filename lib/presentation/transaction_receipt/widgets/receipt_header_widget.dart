import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

/// Receipt Header Widget
///
/// Displays Token V branding, company information, and security verification badge
class ReceiptHeaderWidget extends StatelessWidget {
  final DateTime timestamp;
  final String status;

  const ReceiptHeaderWidget({
    super.key,
    required this.timestamp,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: CustomImageWidget(
              imageUrl: 'assets/images/img_app_logo.svg',
              height: 50,
              width: 50,
            ),
          ),

          SizedBox(height: 2.h),

          // Company Name
          Text(
            'Token V Wallet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 0.5.h),

          // Subtitle
          Text(
            'Official Transaction Receipt',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),

          SizedBox(height: 2.h),

          // Security Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: status == 'completed'
                  ? Colors.green
                  : status == 'pending'
                      ? Colors.orange
                      : Colors.red,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: status == 'completed'
                      ? 'verified_user'
                      : status == 'pending'
                          ? 'pending'
                          : 'error',
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  status == 'completed'
                      ? 'Verified & Secure'
                      : status == 'pending'
                          ? 'Processing'
                          : 'Failed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Date and Time
          Text(
            DateFormat('EEEE, MMM dd, yyyy • HH:mm').format(timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
