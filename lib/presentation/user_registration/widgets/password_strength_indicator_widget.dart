import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Password Strength Indicator Widget
///
/// Visual indicator showing password strength from weak to strong
class PasswordStrengthIndicatorWidget extends StatelessWidget {
  final int strength; // 0-5

  const PasswordStrengthIndicatorWidget({
    super.key,
    required this.strength,
  });

  String get _strengthLabel {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
      case 5:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (strength) {
      case 0:
      case 1:
        return theme.colorScheme.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
      case 5:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strengthColor = _getStrengthColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              _strengthLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? 2.w : 0),
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 1.h),
        Text(
          'Use 8+ characters with uppercase, lowercase, numbers, and symbols',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
