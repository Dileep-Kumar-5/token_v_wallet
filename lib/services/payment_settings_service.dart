import './supabase_service.dart';

class PaymentSettingsService {
  static PaymentSettingsService? _instance;
  static PaymentSettingsService get instance =>
      _instance ??= PaymentSettingsService._();
  PaymentSettingsService._();

  final _client = SupabaseService.instance.client;

  // Currency Settings Methods
  Future<List<Map<String, dynamic>>> getCurrencySettings() async {
    try {
      final response = await _client
          .from('currency_settings')
          .select()
          .eq('is_active', true)
          .order('currency_code');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch currency settings: $error');
    }
  }

  Future<Map<String, dynamic>> updateCurrencySettings(
      String currencyCode, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('currency_settings')
          .update(updates)
          .eq('currency_code', currencyCode)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update currency settings: $error');
    }
  }

  // Country Settings Methods
  Future<List<Map<String, dynamic>>> getCountrySettings() async {
    try {
      final response = await _client
          .from('country_settings')
          .select()
          .eq('is_active', true)
          .order('country_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch country settings: $error');
    }
  }

  Future<Map<String, dynamic>> updateCountrySettings(
      String countryCode, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('country_settings')
          .update(updates)
          .eq('country_code', countryCode)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update country settings: $error');
    }
  }

  // Payment Methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payment_methods')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch payment methods: $error');
    }
  }

  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> paymentMethodData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      paymentMethodData['user_id'] = user.id;

      final response = await _client
          .from('payment_methods')
          .insert(paymentMethodData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to add payment method: $error');
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _client.from('payment_methods').delete().eq('id', paymentMethodId);
    } catch (error) {
      throw Exception('Failed to delete payment method: $error');
    }
  }

  Future<Map<String, dynamic>> setDefaultPaymentMethod(
      String paymentMethodId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('payment_methods')
          .update({'is_default': false}).eq('user_id', user.id);

      final response = await _client
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', paymentMethodId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to set default payment method: $error');
    }
  }

  // Bank Accounts
  Future<List<Map<String, dynamic>>> getUserBankAccounts() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('bank_accounts')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch bank accounts: $error');
    }
  }

  Future<Map<String, dynamic>> addBankAccount(
      Map<String, dynamic> bankAccountData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      bankAccountData['user_id'] = user.id;

      final response = await _client
          .from('bank_accounts')
          .insert(bankAccountData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to add bank account: $error');
    }
  }

  Future<void> deleteBankAccount(String bankAccountId) async {
    try {
      await _client.from('bank_accounts').delete().eq('id', bankAccountId);
    } catch (error) {
      throw Exception('Failed to delete bank account: $error');
    }
  }

  Future<Map<String, dynamic>> setDefaultBankAccount(
      String bankAccountId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('bank_accounts')
          .update({'is_default': false}).eq('user_id', user.id);

      final response = await _client
          .from('bank_accounts')
          .update({'is_default': true})
          .eq('id', bankAccountId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to set default bank account: $error');
    }
  }

  // Payment Transactions
  Future<Map<String, dynamic>> createPaymentTransaction(
      Map<String, dynamic> transactionData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      transactionData['user_id'] = user.id;

      final response = await _client
          .from('payment_transactions')
          .insert(transactionData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create payment transaction: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentTransactions(
      {int limit = 50}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payment_transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch payment transactions: $error');
    }
  }

  // Payout Transactions
  Future<Map<String, dynamic>> createPayoutTransaction(
      Map<String, dynamic> payoutData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      payoutData['user_id'] = user.id;

      final response = await _client
          .from('payout_transactions')
          .insert(payoutData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create payout transaction: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getPayoutTransactions(
      {int limit = 50}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payout_transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch payout transactions: $error');
    }
  }
}
