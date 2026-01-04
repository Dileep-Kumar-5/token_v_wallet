import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Activity Item Widget
///
/// Displays an activity item with swipe actions
class ActivityItemWidget extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onInvestigate;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final VoidCallback onContact;

  const ActivityItemWidget({
    super.key,
    required this.activity,
    required this.onInvestigate,
    required this.onApprove,
    required this.onDeny,
    required this.onContact,
  });

  Color _getSeverityColor(String severity, ThemeData theme) {
    switch (severity) {
      case 'critical':
        return Color(0xFFE74C3C);
      case 'warning':
        return Color(0xFFF39C12);
      case 'info':
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'registration':
        return Icons.person_add;
      case 'transaction':
        return Icons.swap_horiz;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = activity["title"] as String;
    final description = activity["description"] as String;
    final timestamp = activity["timestamp"] as DateTime;
    final severity = activity["severity"] as String;
    final type = activity["type"] as String;
    final avatar = activity["avatar"] as String? ?? '';
    final semanticLabel = activity["semanticLabel"] as String? ?? '';

    return Slidable(
      key: ValueKey(activity["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onInvestigate(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.search,
            label: 'Investigate',
          ),
          if (type == 'transaction') ...[
            SlidableAction(
              onPressed: (context) => onApprove(),
              backgroundColor: Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Approve',
            ),
            SlidableAction(
              onPressed: (context) => onDeny(),
              backgroundColor: Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              icon: Icons.close,
              label: 'Deny',
            ),
          ],
          SlidableAction(
            onPressed: (context) => onContact(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.message,
            label: 'Contact',
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSeverityColor(severity, theme).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (avatar.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: avatar,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                ),
              )
            else
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color:
                      _getSeverityColor(severity, theme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getSeverityColor(severity, theme),
                  size: 20,
                ),
              ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(severity, theme)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          severity.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getSeverityColor(severity, theme),
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _formatTimestamp(timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (activity["amount"] != null) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity["amount"] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
