import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter/foundation.dart';

// Response models for payment processing
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  final String? error;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
    this.error,
  });
}

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Initialize Stripe with publishable key
  static Future<void> initialize() async {
    try {
      const String publishableKey = String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

      if (publishableKey.isEmpty) {
        throw Exception(
            'STRIPE_PUBLISHABLE_KEY must be configured with a valid key');
      }

      // Initialize Stripe for both platforms
      stripe.Stripe.publishableKey = publishableKey;

      // Initialize web-specific settings if on web
      if (kIsWeb) {
        await stripe.Stripe.instance.applySettings();
      }

      if (kDebugMode) {
        print(
            'Stripe initialized successfully for ${kIsWeb ? 'web' : 'mobile'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization error: $e');
      }
      rethrow;
    }
  }

  // Get user's payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('payment_methods')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('is_primary', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch payment methods: $e');
    }
  }

  // Add new payment method
  Future<Map<String, dynamic>> addPaymentMethod({
    required String methodType,
    required String currencyCode,
    String? cardLastFour,
    String? cardBrand,
    int? cardExpiryMonth,
    int? cardExpiryYear,
    String? bankName,
    String? accountLastFour,
    String? walletProvider,
    required String paymentToken,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('payment_methods')
          .insert({
            'user_id': userId,
            'method_type': methodType,
            'currency_code': currencyCode,
            'card_last_four': cardLastFour,
            'card_brand': cardBrand,
            'card_expiry_month': cardExpiryMonth,
            'card_expiry_year': cardExpiryYear,
            'bank_name': bankName,
            'account_last_four': accountLastFour,
            'wallet_provider': walletProvider,
            'payment_token': paymentToken,
            'verification_status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Set primary payment method
  Future<void> setPrimaryPaymentMethod(String paymentMethodId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Remove primary flag from all methods
      await _supabase
          .from('payment_methods')
          .update({'is_primary': false}).eq('user_id', userId);

      // Set new primary
      await _supabase
          .from('payment_methods')
          .update({'is_primary': true})
          .eq('id', paymentMethodId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to set primary payment method: $e');
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('payment_methods')
          .update({'is_active': false})
          .eq('id', paymentMethodId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to remove payment method: $e');
    }
  }

  // Get currency configurations
  Future<List<Map<String, dynamic>>> getCurrencyConfigurations() async {
    try {
      final response = await _supabase
          .from('currency_configurations')
          .select('*')
          .eq('is_active', true)
          .order('currency_code');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch currency configurations: $e');
    }
  }

  // Create purchase transaction
  Future<Map<String, dynamic>> createPurchaseTransaction({
    required String paymentMethodId,
    required double amount,
    required String currencyCode,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get currency configuration
      final currencyConfig = await _supabase
          .from('currency_configurations')
          .select('*')
          .eq('currency_code', currencyCode)
          .eq('is_active', true)
          .single();

      final exchangeRate = currencyConfig['exchange_rate_to_usd'] as double;
      final feePercentage =
          currencyConfig['processing_fee_percentage'] as double;
      final processingFee = amount * (feePercentage / 100);
      final totalAmount = amount + processingFee;
      final tokenAmount = amount * exchangeRate;

      final response = await _supabase
          .from('purchase_transactions')
          .insert({
            'user_id': userId,
            'payment_method_id': paymentMethodId,
            'amount': amount,
            'currency_code': currencyCode,
            'token_amount': tokenAmount,
            'exchange_rate': exchangeRate,
            'processing_fee': processingFee,
            'total_amount': totalAmount,
            'transaction_status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create purchase transaction: $e');
    }
  }

  // Get user's bank accounts
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('bank_accounts')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch bank accounts: $e');
    }
  }

  // Add bank account for payout
  Future<Map<String, dynamic>> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String routingCode,
    required String countryCode,
    required String currencyCode,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    required String postalCode,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('bank_accounts')
          .insert({
            'user_id': userId,
            'account_holder_name': accountHolderName,
            'bank_name': bankName,
            'account_number_encrypted':
                accountNumber, // Should be encrypted in production
            'routing_code': routingCode,
            'country_code': countryCode,
            'currency_code': currencyCode,
            'address_line1': addressLine1,
            'address_line2': addressLine2,
            'city': city,
            'state': state,
            'postal_code': postalCode,
            'verification_status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to add bank account: $e');
    }
  }

  // Upload verification document
  Future<Map<String, dynamic>> uploadVerificationDocument({
    required String bankAccountId,
    required String documentType,
    required String filePath,
    required String fileName,
    required int fileSize,
    required String mimeType,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('verification_documents')
          .insert({
            'user_id': userId,
            'bank_account_id': bankAccountId,
            'document_type': documentType,
            'document_url': filePath,
            'file_name': fileName,
            'file_size': fileSize,
            'mime_type': mimeType,
            'review_status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to upload verification document: $e');
    }
  }

  // Verify micro deposits
  Future<void> verifyMicroDeposits({
    required String bankAccountId,
    required double amount1,
    required double amount2,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get bank account
      final bankAccount = await _supabase
          .from('bank_accounts')
          .select('*')
          .eq('id', bankAccountId)
          .eq('user_id', userId)
          .single();

      // Verify amounts match
      if (bankAccount['micro_deposit_amount1'] == amount1 &&
          bankAccount['micro_deposit_amount2'] == amount2) {
        await _supabase
            .from('bank_accounts')
            .update({'verification_status': 'verified'})
            .eq('id', bankAccountId)
            .eq('user_id', userId);
      } else {
        // Increment attempts
        final attempts = (bankAccount['micro_deposit_attempts'] as int) + 1;
        await _supabase
            .from('bank_accounts')
            .update({'micro_deposit_attempts': attempts})
            .eq('id', bankAccountId)
            .eq('user_id', userId);

        throw Exception('Invalid micro deposit amounts');
      }
    } catch (e) {
      throw Exception('Failed to verify micro deposits: $e');
    }
  }

  // Create Payment Intent for Stripe processing
  Future<PaymentIntentResponse> createPaymentIntent({
    required double amount,
    required String transactionType,
    required String userId,
    String? recipientId,
    String currency = 'usd',
    String paymentMethodType = 'card',
  }) async {
    try {
      // Convert amount to cents (Stripe uses smallest currency unit)
      final int amountInCents = (amount * 100).round();

      // Get currency configuration
      final currencyConfig = await _supabase
          .from('currency_configurations')
          .select('*')
          .eq('currency_code', currency.toUpperCase())
          .eq('is_active', true)
          .single();

      final exchangeRate = currencyConfig['exchange_rate_to_usd'] as double;
      final feePercentage =
          currencyConfig['processing_fee_percentage'] as double;
      final processingFee = amount * (feePercentage / 100);
      final totalAmount = amount + processingFee;
      final tokenAmount = amount * exchangeRate;

      // Create a purchase transaction record first
      final transactionResponse = await _supabase
          .from('purchase_transactions')
          .insert({
            'user_id': userId,
            'amount': amount,
            'currency_code': currency.toUpperCase(),
            'token_amount': tokenAmount,
            'exchange_rate': exchangeRate,
            'processing_fee': processingFee,
            'total_amount': totalAmount,
            'transaction_status': 'pending',
            'transaction_type': transactionType,
            'recipient_id': recipientId,
          })
          .select()
          .single();

      final transactionId = transactionResponse['id'] as String;

      // Create Stripe Payment Intent via Edge Function
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amountInCents,
          'currency': currency,
          'transactionId': transactionId,
          'userId': userId,
          'transactionType': transactionType,
          'recipientId': recipientId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create payment intent: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      return PaymentIntentResponse(
        clientSecret: data['clientSecret'] as String,
        paymentIntentId: data['paymentIntentId'] as String,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Process Payment using unified CardField + confirmPayment approach
  Future<PaymentResult> processPayment({
    required String clientSecret,
    required String merchantDisplayName,
    required stripe.BillingDetails billingDetails,
  }) async {
    try {
      // Validate client secret
      if (clientSecret.isEmpty) {
        throw Exception('Invalid payment configuration');
      }

      // Check if Stripe is properly initialized
      if (stripe.Stripe.publishableKey.isEmpty) {
        throw Exception('Payment service not properly initialized');
      }

      // Confirm payment directly with CardField data
      final paymentIntent = await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // Check payment status
      if (paymentIntent.status == stripe.PaymentIntentsStatus.Succeeded) {
        // Verify and complete payment
        final result = await _verifyAndCompletePayment(clientSecret);

        return PaymentResult(
          success: true,
          message: 'Payment completed successfully',
          transactionId: result['transactionId'] as String?,
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment was not completed. Status: ${paymentIntent.status}',
        );
      }
    } on stripe.StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: _getStripeErrorMessage(e),
        error: e.error.code.name,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  // Get user-friendly error message from Stripe error
  String _getStripeErrorMessage(stripe.StripeException e) {
    switch (e.error.code) {
      case stripe.FailureCode.Canceled:
        return 'Payment was cancelled';
      case stripe.FailureCode.Failed:
        return 'Payment failed. Please try again.';
      case stripe.FailureCode.Timeout:
        return 'Payment timed out. Please try again.';
      default:
        return e.error.localizedMessage ?? 'Payment failed. Please try again.';
    }
  }

  // Verify and complete payment transaction
  Future<Map<String, dynamic>> _verifyAndCompletePayment(
      String clientSecret) async {
    try {
      // Call Edge Function to verify payment with Stripe
      final response = await _supabase.functions.invoke(
        'verify-payment',
        body: {
          'clientSecret': clientSecret,
        },
      );

      if (response.status != 200) {
        throw Exception('Payment verification failed');
      }

      final data = response.data as Map<String, dynamic>;
      final transactionId = data['transactionId'] as String;
      final paymentStatus = data['paymentStatus'] as String;

      if (paymentStatus == 'succeeded') {
        // Update transaction status to completed
        await _supabase.from('purchase_transactions').update({
          'transaction_status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', transactionId);

        // Add tokens to user wallet if transaction type is fund_wallet
        final transaction = await _supabase
            .from('purchase_transactions')
            .select('*')
            .eq('id', transactionId)
            .single();

        if (transaction['transaction_type'] == 'fund_wallet') {
          await _creditUserWallet(
            transaction['user_id'] as String,
            transaction['token_amount'] as double,
            transactionId,
          );
        }

        return {
          'transactionId': transactionId,
          'status': 'completed',
        };
      } else {
        // Update transaction to failed
        await _supabase.from('purchase_transactions').update({
          'transaction_status': 'failed',
        }).eq('id', transactionId);

        throw Exception('Payment verification failed: $paymentStatus');
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Credit user wallet with purchased tokens
  Future<void> _creditUserWallet(
      String userId, double tokenAmount, String transactionId) async {
    try {
      // Call stored procedure to credit wallet
      await _supabase.rpc('credit_user_wallet', params: {
        'p_user_id': userId,
        'p_amount': tokenAmount,
        'p_transaction_reference': transactionId,
        'p_transaction_type': 'purchase',
      });
    } catch (e) {
      throw Exception('Failed to credit wallet: $e');
    }
  }
}
