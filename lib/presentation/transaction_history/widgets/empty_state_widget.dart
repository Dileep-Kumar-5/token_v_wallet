import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty State Widget
///
/// Displays when there are no transactions to show
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onStartSending;

  const EmptyStateWidget({
    super.key,
    required this.onStartSending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'receipt_long',
                  color: theme.colorScheme.primary,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transactions Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start sending Token V credits to see your transaction history here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onStartSending,
              icon: CustomIconWidget(
                iconName: 'send',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Start Sending Credits'),
            ),
          ],
        ),
      ),
    );
  }
}
