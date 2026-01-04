import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Reconciliation Card Widget
///
/// Displays balance reconciliation report with accuracy metrics
class ReconciliationCardWidget extends StatelessWidget {
  final Map<String, dynamic> reconciliationData;

  const ReconciliationCardWidget({
    super.key,
    required this.reconciliationData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary =
        reconciliationData['summary'] as Map<String, dynamic>? ?? {};
    final totalUsers = summary['total_users'] as int? ?? 0;
    final validBalances = summary['valid_balances'] as int? ?? 0;
    final discrepancies = summary['discrepancies'] as int? ?? 0;
    final accuracyRate = summary['accuracy_rate'] as double? ?? 100.0;
    final totalDifference = summary['total_difference'] as double? ?? 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'account_balance',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Reconciliation Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Automated balance verification',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Accuracy Rate Circle
          Center(
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: CircularProgressIndicator(
                      value: accuracyRate / 100,
                      strokeWidth: 8,
                      backgroundColor:
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accuracyRate >= 95
                            ? theme.colorScheme.primary
                            : accuracyRate >= 90
                                ? const Color(0xFFF39C12)
                                : theme.colorScheme.error,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${accuracyRate.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accuracyRate >= 95
                              ? theme.colorScheme.primary
                              : accuracyRate >= 90
                                  ? const Color(0xFFF39C12)
                                  : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        'Accuracy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Summary Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Users',
                  totalUsers.toString(),
                  'people',
                  theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Valid',
                  validBalances.toString(),
                  'check_circle',
                  const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Discrepancies',
                  discrepancies.toString(),
                  'warning',
                  discrepancies > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Difference',
                  NumberFormat.currency(symbol: '\$')
                      .format(totalDifference.abs()),
                  'account_balance_wallet',
                  totalDifference != 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          SizedBox(height: 1.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: CustomIconWidget(
                    iconName: 'list_alt',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('View Details'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: CustomIconWidget(
                    iconName: 'file_download',
                    color: theme.colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text('Export'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String iconName,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
