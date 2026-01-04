import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:sizer/sizer.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessingPayment = false;
  String? _message;
  String? _errorMessage;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Transaction details
  String _transactionType = 'fund_wallet';
  double _amount = 0.0;
  String? _recipientId;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
    _loadUserData();
  }

  Future<void> _initializePaymentService() async {
    try {
      // Remove this line - PaymentService.initialize() doesn't exist
      setState(() {
        _message = 'Payment service ready';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment service unavailable: $e';
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = SupabaseService.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _transactionType = args['transactionType'] ?? 'fund_wallet';
        _amount = args['amount'] ?? 0.0;
        _recipientId = args['recipientId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title:
            _transactionType == 'fund_wallet' ? 'Fund Wallet' : 'Send Credits',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Transaction Summary Card
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Summary',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Type:',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[700]),
                          ),
                          Text(
                            _transactionType == 'fund_wallet'
                                ? 'Wallet Funding'
                                : 'Credit Transfer',
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount:',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[700]),
                          ),
                          Text(
                            '\$${_amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Billing Information
                        Text(
                          'Billing Information',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),

                        _buildTextField(
                            _nameController, 'Full Name', true, Icons.person),
                        _buildTextField(
                            _emailController, 'Email', true, Icons.email),
                        _buildTextField(
                            _phoneController, 'Phone', true, Icons.phone),
                        _buildTextField(_addressLine1Controller, 'Address',
                            true, Icons.location_on),
                        Row(
                          children: [
                            Expanded(
                                child: _buildTextField(_cityController, 'City',
                                    true, Icons.location_city)),
                            SizedBox(width: 3.w),
                            Expanded(
                                child: _buildTextField(_stateController,
                                    'State', true, Icons.map)),
                          ],
                        ),
                        _buildTextField(_zipCodeController, 'Zip Code', true,
                            Icons.pin_drop),

                        SizedBox(height: 3.h),

                        // Payment Information
                        Text(
                          'Payment Information',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.all(4.w),
                          child: stripe.CardField(
                            onCardChanged: (card) {
                              if (_errorMessage != null &&
                                  _errorMessage!.contains('card')) {
                                setState(() => _errorMessage = null);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Card Information',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              border: InputBorder.none,
                              helperText: 'Enter your card details',
                              helperStyle: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey[600]),
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Messages
                        if (_message != null)
                          Container(
                            padding: EdgeInsets.all(3.w),
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green[200]!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16.sp),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(_message!,
                                      style: TextStyle(
                                          color: Colors.green[800],
                                          fontSize: 12.sp)),
                                ),
                              ],
                            ),
                          ),
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(3.w),
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red[200]!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.error,
                                    color: Colors.red, size: 16.sp),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(_errorMessage!,
                                      style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 12.sp)),
                                ),
                              ],
                            ),
                          ),

                        // Pay Button
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed:
                                _isProcessingPayment ? null : _handlePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                            ),
                            child: _isProcessingPayment
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16.sp,
                                        height: 16.sp,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      ),
                                      SizedBox(width: 3.w),
                                      Text('Processing...',
                                          style: TextStyle(fontSize: 14.sp)),
                                    ],
                                  )
                                : Text('Pay \$${_amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool required, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _message = 'Creating Payment Intent...';
      _errorMessage = null;
    });

    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create Payment Intent
      final paymentIntentResponse = await PaymentService().createPaymentIntent(
        amount: _amount,
        transactionType: _transactionType,
        userId: user.id,
        recipientId: _recipientId,
        currency: 'usd',
        paymentMethodType: 'card',
      );

      setState(() {
        _message = 'Processing Payment...';
      });

      // Create billing details
      final billingDetails = stripe.BillingDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: stripe.Address(
          line1: _addressLine1Controller.text,
          line2: '',
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _zipCodeController.text,
          country: 'US',
        ),
      );

      // Process payment
      final result = await PaymentService().processPayment(
        clientSecret: paymentIntentResponse.clientSecret,
        merchantDisplayName: 'Token V Wallet',
        billingDetails: billingDetails,
      );

      if (result.success) {
        setState(() {
          _message = result.message;
          _errorMessage = null;
        });
        _showSuccessDialog(paymentIntentResponse.paymentIntentId);
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _message = null;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showSuccessDialog(String paymentIntentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
              SizedBox(width: 3.w),
              Text('Success', style: TextStyle(fontSize: 18.sp)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your payment has been processed successfully!',
                  style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 2.h),
              Text('Payment ID: $paymentIntentId',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              Text('Amount: \$${_amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}
