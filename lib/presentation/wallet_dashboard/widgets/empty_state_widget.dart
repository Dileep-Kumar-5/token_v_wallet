import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Empty State Widget
///
/// Displayed when user has no transactions
/// Features: Illustration, CTA to send first credits
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onSendCredits;

  const EmptyStateWidget({
    super.key,
    required this.onSendCredits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // Illustration
          CustomImageWidget(
            imageUrl:
                'https://images.unsplash.com/photo-1633158829585-23ba8f7c8caf?w=400',
            width: 60.w,
            height: 30.h,
            fit: BoxFit.contain,
            semanticLabel:
                'Illustration of a person holding a smartphone with digital wallet interface',
          ),

          SizedBox(height: 4.h),

          // Empty state text
          Text(
            'No Transactions Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Start sending Token V credits to your contacts and build your transaction history',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSendCredits,
              icon: CustomIconWidget(
                iconName: 'send',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Send Your First Credits',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
