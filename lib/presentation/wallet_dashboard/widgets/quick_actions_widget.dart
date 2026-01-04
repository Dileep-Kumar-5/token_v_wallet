import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick Actions Widget
///
/// Provides thumb-reachable action buttons for common wallet operations
/// Features: Send Credits, Request Credits, Transaction History
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onSendCredits;
  final VoidCallback onRequestCredits;
  final VoidCallback onViewHistory;

  const QuickActionsWidget({
    super.key,
    required this.onSendCredits,
    required this.onRequestCredits,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: 'send',
                  label: 'Send Credits',
                  onTap: onSendCredits,
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _QuickActionButton(
                  icon: 'call_received',
                  label: 'Request',
                  onTap: onRequestCredits,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _QuickActionButton(
                  icon: 'history',
                  label: 'History',
                  onTap: onViewHistory,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isPrimary ? 4 : 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
