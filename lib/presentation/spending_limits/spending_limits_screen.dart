import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/transaction_security_service.dart';

/// Spending Limits Screen
/// Allows users to set and manage their spending limits
class SpendingLimitsScreen extends StatefulWidget {
  const SpendingLimitsScreen({super.key});

  @override
  State<SpendingLimitsScreen> createState() => _SpendingLimitsScreenState();
}

class _SpendingLimitsScreenState extends State<SpendingLimitsScreen> {
  final _dailyController = TextEditingController();
  final _monthlyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  Future<void> _loadLimits() async {
    setState(() => _isLoading = true);

    try {
      final dailyLimit = await TransactionSecurityService.getDailyLimit();
      final monthlyLimit = await TransactionSecurityService.getMonthlyLimit();

      _dailyController.text = dailyLimit.toStringAsFixed(0);
      _monthlyController.text = monthlyLimit.toStringAsFixed(0);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLimits() async {
    final daily = double.tryParse(_dailyController.text);
    final monthly = double.tryParse(_monthlyController.text);

    if (daily == null || monthly == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amounts')),
      );
      return;
    }

    if (daily > monthly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Daily limit cannot exceed monthly limit')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await TransactionSecurityService.setDailyLimit(daily);
      await TransactionSecurityService.setMonthlyLimit(monthly);

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spending limits updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update limits')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Spending Limits',
        variant: CustomAppBarVariant.standard,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Set limits to protect your account from unauthorized large transactions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Daily limit
                  Text(
                    'Daily Limit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _dailyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      hintText: 'Enter daily limit',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Monthly limit
                  Text(
                    'Monthly Limit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _monthlyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      hintText: 'Enter monthly limit',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Security features
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Security',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        _buildSecurityFeature(
                          theme,
                          icon: 'verified_user',
                          title: 'High-value verification',
                          description:
                              'Transactions over \$500 require biometric verification',
                        ),
                        SizedBox(height: 1.h),
                        _buildSecurityFeature(
                          theme,
                          icon: 'speed',
                          title: 'Velocity checking',
                          description:
                              'Rapid transactions are automatically flagged',
                        ),
                        SizedBox(height: 1.h),
                        _buildSecurityFeature(
                          theme,
                          icon: 'security',
                          title: 'Pattern detection',
                          description:
                              'Suspicious patterns trigger additional checks',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveLimits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Save Limits',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSecurityFeature(
    ThemeData theme, {
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
