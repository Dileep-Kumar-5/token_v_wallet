import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/payment_service.dart';
import './widgets/add_payment_method_form_widget.dart';
import './widgets/currency_selector_widget.dart';
import './widgets/payment_method_card_widget.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _currencies = [];
  String _selectedCurrency = 'USD';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final methods = await _paymentService.getPaymentMethods();
      final currencies = await _paymentService.getCurrencyConfigurations();

      setState(() {
        _paymentMethods = methods;
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showAddPaymentMethodForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPaymentMethodFormWidget(
        selectedCurrency: _selectedCurrency,
        onPaymentMethodAdded: () {
          Navigator.pop(context);
          _loadData();
        },
      ),
    );
  }

  Future<void> _setPrimary(String methodId) async {
    try {
      await _paymentService.setPrimaryPaymentMethod(methodId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary payment method updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeMethod(String methodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content:
            const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _paymentService.removePaymentMethod(methodId);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment method removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
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
          'Payment Methods',
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
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Currency Selector
                        CurrencySelectorWidget(
                          currencies: _currencies,
                          selectedCurrency: _selectedCurrency,
                          onCurrencyChanged: (currency) {
                            setState(() => _selectedCurrency = currency);
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Payment Methods Section
                        Text(
                          'Saved Payment Methods',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        _paymentMethods.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.credit_card_outlined,
                                      size: 48.sp,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'No payment methods added yet',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _paymentMethods.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 2.h),
                                itemBuilder: (context, index) {
                                  final method = _paymentMethods[index];
                                  return PaymentMethodCardWidget(
                                    method: method,
                                    onSetPrimary: () =>
                                        _setPrimary(method['id']),
                                    onRemove: () => _removeMethod(method['id']),
                                  );
                                },
                              ),

                        SizedBox(height: 3.h),

                        // Add Payment Method Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showAddPaymentMethodForm,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Payment Method'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Security Section
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.blue[700],
                                size: 24.sp,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Secure Payments',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'All payment data is encrypted and PCI compliant',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
