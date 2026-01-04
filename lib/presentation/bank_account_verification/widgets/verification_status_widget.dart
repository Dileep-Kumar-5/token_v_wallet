import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/payment_service.dart';

class VerificationStatusWidget extends StatefulWidget {
  final String bankAccountId;

  const VerificationStatusWidget({
    super.key,
    required this.bankAccountId,
  });

  @override
  State<VerificationStatusWidget> createState() =>
      _VerificationStatusWidgetState();
}

class _VerificationStatusWidgetState extends State<VerificationStatusWidget> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic>? _bankAccount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBankAccount();
  }

  Future<void> _loadBankAccount() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _paymentService.getBankAccounts();
      final account = accounts.firstWhere(
        (a) => a['id'] == widget.bankAccountId,
        orElse: () => {},
      );

      setState(() {
        _bankAccount = account;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bankAccount == null) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Text('Bank account not found'),
      );
    }

    final status = _bankAccount!['verification_status'] as String;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(status),
              size: 48.sp,
              color: _getStatusColor(status),
            ),
          ),
          SizedBox(height: 3.h),

          // Status Title
          Text(
            _getStatusTitle(status),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Status Description
          Text(
            _getStatusDescription(status),
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Status Details
          _buildStatusDetails(status),

          SizedBox(height: 3.h),

          // Action Button
          if (status == 'verified')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Complete'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusDetails(String status) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildStatusRow(
              'Documents Submitted', Icons.check_circle, Colors.green),
          SizedBox(height: 2.h),
          _buildStatusRow(
            'Under Review',
            status == 'under_review' || status == 'verified'
                ? Icons.check_circle
                : Icons.hourglass_empty,
            status == 'under_review' || status == 'verified'
                ? Colors.green
                : Colors.grey,
          ),
          SizedBox(height: 2.h),
          _buildStatusRow(
            'Verification Complete',
            status == 'verified' ? Icons.check_circle : Icons.hourglass_empty,
            status == 'verified' ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.verified;
      case 'under_review':
        return Icons.pending;
      case 'pending':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'under_review':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'verified':
        return 'Verification Complete!';
      case 'under_review':
        return 'Under Review';
      case 'pending':
        return 'Verification Pending';
      case 'failed':
        return 'Verification Failed';
      default:
        return 'Processing';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'verified':
        return 'Your bank account has been successfully verified. You can now receive payouts.';
      case 'under_review':
        return 'Our team is reviewing your documents. This typically takes 1-3 business days.';
      case 'pending':
        return 'Your documents have been received and are queued for review.';
      case 'failed':
        return 'Verification failed. Please contact support or resubmit documents.';
      default:
        return 'Processing your verification request.';
    }
  }
}
