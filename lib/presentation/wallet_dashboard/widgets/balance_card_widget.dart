import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Balance Card Widget
///
/// Displays user's Token V credit balance with privacy toggle
/// Features: Large typography for glanceability, show/hide toggle, loading state
class BalanceCardWidget extends StatelessWidget {
  final double balance;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool isRefreshing;

  const BalanceCardWidget({
    super.key,
    required this.balance,
    required this.isVisible,
    required this.onToggleVisibility,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: isVisible ? 'visibility' : 'visibility_off',
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
                onPressed: onToggleVisibility,
                tooltip: isVisible ? 'Hide balance' : 'Show balance',
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Balance amount
          isRefreshing
              ? SizedBox(
                  height: 8.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isVisible
                      ? Text(
                          '\$${balance.toStringAsFixed(2)}',
                          key: const ValueKey('visible'),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        )
                      : Text(
                          '••••••',
                          key: const ValueKey('hidden'),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 8,
                          ),
                        ),
                ),

          SizedBox(height: 1.h),

          // Token V Credits label
          Text(
            'Token V Credits',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 2.h),

          // Last updated timestamp
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                'Last updated: ${_formatTimestamp(DateTime.now())}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
