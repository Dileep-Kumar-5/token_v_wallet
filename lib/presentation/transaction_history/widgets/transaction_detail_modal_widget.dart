import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';

/// Transaction Detail Modal Widget
///
/// Displays detailed information about a transaction
class TransactionDetailModalWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailModalWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final fees = transaction['fees'] as double;
    final status = transaction['status'] as String;
    final timestamp = transaction['timestamp'] as DateTime;

    final isSent = type == 'sent';
    final isPending = status == 'pending';

    final amountColor = isSent ? Colors.red.shade600 : Colors.green.shade600;

    final statusColor =
        isPending ? Colors.orange.shade600 : Colors.green.shade600;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Contact info
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: transaction['contactAvatar'] as String,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          semanticLabel: transaction['semanticLabel'] as String,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      transaction['contactName'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Amount
                    Text(
                      '${isSent ? '-' : '+'}\$${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Token V Credits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details
                    _buildDetailRow(
                      'Transaction ID',
                      transaction['id'] as String,
                      theme,
                    ),
                    _buildDetailRow(
                      'Type',
                      isSent ? 'Sent' : 'Received',
                      theme,
                    ),
                    _buildDetailRow(
                      'Date & Time',
                      DateFormat('MMM dd, yyyy HH:mm').format(timestamp),
                      theme,
                    ),
                    _buildDetailRow(
                      'Fees',
                      '\$${fees.toStringAsFixed(2)}',
                      theme,
                    ),
                    if (transaction['note'] != null)
                      _buildDetailRow(
                        'Note',
                        transaction['note'] as String,
                        theme,
                      ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Receipt downloaded')),
                              );
                            },
                            icon: CustomIconWidget(
                              iconName: 'download',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            label: const Text('Download'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Receipt shared')),
                              );
                            },
                            icon: CustomIconWidget(
                              iconName: 'share',
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
