import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Amount Breakdown Widget
///
/// Shows comprehensive breakdown of transaction amounts including base amount,
/// processing fees, network charges, and final total
class AmountBreakdownWidget extends StatelessWidget {
  final double amount;
  final double fees;

  const AmountBreakdownWidget({
    super.key,
    required this.amount,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final networkCharge = 0.0;
    final total = amount + fees + networkCharge;

    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAmountRow(
            context,
            'Base Amount',
            amount,
            isHighlighted: false,
          ),
          SizedBox(height: 1.h),
          _buildAmountRow(
            context,
            'Processing Fees',
            fees,
            isHighlighted: false,
          ),
          SizedBox(height: 1.h),
          _buildAmountRow(
            context,
            'Network Charges',
            networkCharge,
            isHighlighted: false,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Divider(
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          _buildAmountRow(
            context,
            'Total Amount',
            total,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount, {
    required bool isHighlighted,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
