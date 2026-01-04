import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/payment_service.dart';
import './widgets/bank_details_form_widget.dart';
import './widgets/document_upload_widget.dart';
import './widgets/verification_status_widget.dart';

class BankAccountVerificationScreen extends StatefulWidget {
  const BankAccountVerificationScreen({super.key});

  @override
  State<BankAccountVerificationScreen> createState() =>
      _BankAccountVerificationScreenState();
}

class _BankAccountVerificationScreenState
    extends State<BankAccountVerificationScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _bankAccounts = [];
  int _currentStep = 0;
  bool _isLoading = true;
  String? _currentBankAccountId;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _paymentService.getBankAccounts();
      setState(() {
        _bankAccounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  void _onBankDetailsSubmitted(String bankAccountId) {
    setState(() {
      _currentBankAccountId = bankAccountId;
      _currentStep = 1;
    });
  }

  void _onDocumentsUploaded() {
    setState(() => _currentStep = 2);
    _loadBankAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Account Verification',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Indicator
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            _buildStepIndicator(
                                0, 'Bank Details', _currentStep >= 0),
                            Expanded(
                              child: Container(
                                height: 2.0,
                                color: _currentStep >= 1
                                    ? Colors.blue
                                    : Colors.grey[300],
                              ),
                            ),
                            _buildStepIndicator(
                                1, 'Documents', _currentStep >= 1),
                            Expanded(
                              child: Container(
                                height: 2.0,
                                color: _currentStep >= 2
                                    ? Colors.blue
                                    : Colors.grey[300],
                              ),
                            ),
                            _buildStepIndicator(
                                2, 'Verification', _currentStep >= 2),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Step Content
                      if (_currentStep == 0)
                        BankDetailsFormWidget(
                          onBankDetailsSubmitted: _onBankDetailsSubmitted,
                        )
                      else if (_currentStep == 1)
                        DocumentUploadWidget(
                          bankAccountId: _currentBankAccountId!,
                          onDocumentsUploaded: _onDocumentsUploaded,
                        )
                      else
                        VerificationStatusWidget(
                          bankAccountId: _currentBankAccountId!,
                        ),

                      SizedBox(height: 3.h),

                      // Existing Accounts
                      if (_bankAccounts.isNotEmpty) ...[
                        Text(
                          'Existing Bank Accounts',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _bankAccounts.length,
                          separatorBuilder: (_, __) => SizedBox(height: 2.h),
                          itemBuilder: (context, index) {
                            final account = _bankAccounts[index];
                            return _buildBankAccountCard(account);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountCard(Map<String, dynamic> account) {
    final status = account['verification_status'] as String;
    final bankName = account['bank_name'] as String;
    final accountHolder = account['account_holder_name'] as String;
    final currency = account['currency_code'] as String;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.account_balance,
              color: Colors.blue[700],
              size: 24.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  accountHolder,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withAlpha(26),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      currency,
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
        ],
      ),
    );
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
}
