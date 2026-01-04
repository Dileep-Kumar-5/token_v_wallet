import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for previewing transaction details before confirmation
class TransactionPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> recipient;
  final double amount;
  final double currentBalance;
  final VoidCallback onEdit;

  const TransactionPreviewWidget({
    super.key,
    required this.recipient,
    required this.amount,
    required this.currentBalance,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newBalance = currentBalance - amount;

    return Column(
      children: [
        // Transaction card
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Recipient info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CustomImageWidget(
                      imageUrl: recipient["avatar"] ?? "",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      semanticLabel:
                          recipient["semanticLabel"] ?? "Recipient avatar",
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sending to',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          recipient["name"] ?? "",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          recipient["username"] ?? "",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: onEdit,
                  ),
                ],
              ),

              Divider(height: 4.h),

              // Amount
              Column(
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              Divider(height: 4.h),

              // Transaction details
              _buildDetailRow('Processing Time', 'Instant', theme),
              SizedBox(height: 2.h),
              _buildDetailRow('Transaction Fee', '\$0.00', theme),
              SizedBox(height: 2.h),
              _buildDetailRow(
                  'Total Amount', '\$${amount.toStringAsFixed(2)}', theme),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Balance summary
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildBalanceRow('Current Balance', currentBalance, theme),
              SizedBox(height: 1.h),
              _buildBalanceRow('Amount to Send', -amount, theme,
                  isNegative: true),
              Divider(height: 2.h),
              _buildBalanceRow('New Balance', newBalance, theme, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isNegative ? theme.colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}
