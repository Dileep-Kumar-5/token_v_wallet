import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/payment_service.dart';

class AddPaymentMethodFormWidget extends StatefulWidget {
  final String selectedCurrency;
  final VoidCallback onPaymentMethodAdded;

  const AddPaymentMethodFormWidget({
    super.key,
    required this.selectedCurrency,
    required this.onPaymentMethodAdded,
  });

  @override
  State<AddPaymentMethodFormWidget> createState() =>
      _AddPaymentMethodFormWidgetState();
}

class _AddPaymentMethodFormWidgetState
    extends State<AddPaymentMethodFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  String _methodType = 'credit_card';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Extract card details
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final lastFour = cardNumber.substring(cardNumber.length - 4);
      final expiry = _expiryController.text.split('/');
      final expiryMonth = int.parse(expiry[0].trim());
      final expiryYear = int.parse('20${expiry[1].trim()}');

      // In production, tokenize the card through payment gateway
      final paymentToken = 'tok_${DateTime.now().millisecondsSinceEpoch}';

      await _paymentService.addPaymentMethod(
        methodType: _methodType,
        currencyCode: widget.selectedCurrency,
        cardLastFour: lastFour,
        cardBrand: _detectCardBrand(cardNumber),
        cardExpiryMonth: expiryMonth,
        cardExpiryYear: expiryYear,
        paymentToken: paymentToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully')),
        );
        widget.onPaymentMethodAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'Amex';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Payment Method',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Method Type Selector
                DropdownButtonFormField<String>(
                  initialValue: _methodType,
                  decoration: InputDecoration(
                    labelText: 'Payment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'credit_card',
                      child: Text('Credit Card'),
                    ),
                    DropdownMenuItem(
                      value: 'debit_card',
                      child: Text('Debit Card'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _methodType = value!);
                  },
                ),
                SizedBox(height: 2.h),

                // Card Number
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    final cleaned = value.replaceAll(' ', '');
                    if (cleaned.length < 13 || cleaned.length > 19) {
                      return 'Invalid card number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),

                Row(
                  children: [
                    // Expiry Date
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!value.contains('/') || value.length != 5) {
                            return 'Use MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // CVV
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (value.length < 3 || value.length > 4) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addPaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.sp,
                            width: 20.sp,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text('Add Payment Method'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
