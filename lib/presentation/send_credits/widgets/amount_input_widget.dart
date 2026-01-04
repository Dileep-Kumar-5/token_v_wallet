import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for entering transfer amount with validation
class AmountInputWidget extends StatefulWidget {
  final double currentBalance;
  final Function(double) onAmountChanged;
  final VoidCallback onContinue;

  const AmountInputWidget({
    super.key,
    required this.currentBalance,
    required this.onAmountChanged,
    required this.onContinue,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  final TextEditingController _amountController = TextEditingController();
  String _errorMessage = '';
  bool _isValid = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage = '';
        _isValid = false;
        widget.onAmountChanged(0.0);
        return;
      }

      final amount = double.tryParse(value);
      if (amount == null) {
        _errorMessage = 'Please enter a valid amount';
        _isValid = false;
        widget.onAmountChanged(0.0);
        return;
      }

      if (amount <= 0) {
        _errorMessage = 'Amount must be greater than \$0';
        _isValid = false;
        widget.onAmountChanged(0.0);
        return;
      }

      if (amount > widget.currentBalance) {
        _errorMessage = 'Insufficient balance';
        _isValid = false;
        widget.onAmountChanged(0.0);
        return;
      }

      _errorMessage = '';
      _isValid = true;
      widget.onAmountChanged(amount);
    });
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
    _validateAmount(_amountController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much would you like to send?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 2.h),

        // Current balance display
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${widget.currentBalance.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Amount input field
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorMessage.isNotEmpty
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: _validateAmount,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 4.w, top: 2.h),
                child: Text(
                  '\$',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              hintText: '0.00',
              hintStyle: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
        ),

        if (_errorMessage.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: theme.colorScheme.error,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                _errorMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 3.h),

        // Quick amount buttons
        Text(
          'Quick amounts',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildQuickAmountButton(10.0, theme),
            _buildQuickAmountButton(25.0, theme),
            _buildQuickAmountButton(50.0, theme),
            _buildQuickAmountButton(100.0, theme),
            _buildQuickAmountButton(250.0, theme),
            _buildQuickAmountButton(500.0, theme),
          ],
        ),

        SizedBox(height: 4.h),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isValid ? widget.onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor:
                  theme.colorScheme.surfaceContainerHighest,
              disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue',
              style: theme.textTheme.titleMedium?.copyWith(
                color: _isValid
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(double amount, ThemeData theme) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(0)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
