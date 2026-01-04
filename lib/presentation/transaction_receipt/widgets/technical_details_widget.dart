import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Technical Details Widget
///
/// Displays technical information including transaction ID, blockchain hash,
/// timestamp, processing duration, and confirmation status
class TechnicalDetailsWidget extends StatelessWidget {
  final String transactionId;
  final String transactionHash;
  final DateTime timestamp;
  final String status;
  final Function(String text, String label) onCopy;

  const TechnicalDetailsWidget({
    super.key,
    required this.transactionId,
    required this.transactionHash,
    required this.timestamp,
    required this.status,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            context,
            'Transaction ID',
            transactionId,
            copyable: true,
          ),
          SizedBox(height: 1.h),
          _buildDetailRow(
            context,
            'Blockchain Hash',
            transactionHash,
            copyable: true,
          ),
          SizedBox(height: 1.h),
          _buildDetailRow(
            context,
            'Timestamp',
            DateFormat('MMM dd, yyyy HH:mm:ss').format(timestamp),
            copyable: false,
          ),
          SizedBox(height: 1.h),
          _buildDetailRow(
            context,
            'Processing Duration',
            '< 1 second',
            copyable: false,
          ),
          SizedBox(height: 1.h),
          _buildDetailRow(
            context,
            'Confirmations',
            '6/6',
            copyable: false,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security Level',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'High',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required bool copyable,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: copyable ? 'monospace' : null,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (copyable) ...[
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => onCopy(value, label),
                  child: CustomIconWidget(
                    iconName: 'content_copy',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
