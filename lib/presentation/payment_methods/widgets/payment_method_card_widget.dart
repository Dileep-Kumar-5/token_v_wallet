import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentMethodCardWidget extends StatelessWidget {
  final Map<String, dynamic> method;
  final VoidCallback onSetPrimary;
  final VoidCallback onRemove;

  const PaymentMethodCardWidget({
    Key? key,
    required this.method,
    required this.onSetPrimary,
    required this.onRemove,
  }) : super(key: key);

  IconData _getMethodIcon() {
    final type = method['method_type'] as String;
    switch (type) {
      case 'credit_card':
      case 'debit_card':
        return Icons.credit_card;
      case 'bank_account':
        return Icons.account_balance;
      case 'digital_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getMethodDisplay() {
    final type = method['method_type'] as String;
    if (type == 'credit_card' || type == 'debit_card') {
      final brand = method['card_brand'] ?? 'Card';
      final lastFour = method['card_last_four'] ?? '****';
      return '$brand •••• $lastFour';
    } else if (type == 'bank_account') {
      final bank = method['bank_name'] ?? 'Bank';
      final lastFour = method['account_last_four'] ?? '****';
      return '$bank •••• $lastFour';
    } else {
      final provider = method['wallet_provider'] ?? 'Digital Wallet';
      return provider;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = method['is_primary'] as bool? ?? false;
    final status = method['verification_status'] as String;
    final currencyCode = method['currency_code'] as String;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: isPrimary
            ? Border.all(color: Colors.blue, width: 2.0)
            : Border.all(color: Colors.grey[300]!, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  _getMethodIcon(),
                  color: Colors.blue[700],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getMethodDisplay(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isPrimary) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Container(
                          width: 8.sp,
                          height: 8.sp,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(status),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          currencyCode,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20.sp),
                onSelected: (value) {
                  if (value == 'primary') {
                    onSetPrimary();
                  } else if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) => [
                  if (!isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Set as Primary'),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
          if (method['card_expiry_month'] != null) ...[
            SizedBox(height: 2.h),
            Text(
              'Expires ${method['card_expiry_month']}/${method['card_expiry_year']}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
