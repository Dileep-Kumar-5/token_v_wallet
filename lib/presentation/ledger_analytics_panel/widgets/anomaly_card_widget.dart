import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Anomaly Card Widget
///
/// Displays detected anomalies with severity ratings and recommended actions
class AnomalyCardWidget extends StatelessWidget {
  final Map<String, dynamic> anomaly;

  const AnomalyCardWidget({
    super.key,
    required this.anomaly,
  });

  Color _getSeverityColor(BuildContext context, String severity) {
    final theme = Theme.of(context);
    switch (severity) {
      case 'critical':
        return theme.colorScheme.error;
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return 'error';
      case 'high':
        return 'warning';
      case 'medium':
        return 'info';
      default:
        return 'check_circle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = anomaly['severity'] as String? ?? 'medium';
    final type = anomaly['type'] as String? ?? 'Unknown Anomaly';
    final description = anomaly['description'] as String? ?? '';
    final amount = (anomaly['amount'] as num?)?.toDouble() ?? 0.0;
    final timestamp = anomaly['timestamp'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSeverityColor(context, severity).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getSeverityColor(context, severity)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getSeverityIcon(severity),
                  color: _getSeverityColor(context, severity),
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(context, severity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${severity.toUpperCase()} SEVERITY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(amount.abs()),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getSeverityColor(context, severity),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Detected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    timestamp != null
                        ? DateFormat('MMM dd, HH:mm')
                            .format(DateTime.parse(timestamp))
                        : 'N/A',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _getSeverityColor(context, severity),
                    ),
                  ),
                  child: Text('Investigate'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getSeverityColor(context, severity),
                  ),
                  child: Text('Take Action'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
