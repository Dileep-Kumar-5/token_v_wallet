import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/payment_settings_service.dart';

class CurrencyConfigTabWidget extends StatefulWidget {
  const CurrencyConfigTabWidget({super.key});

  @override
  State<CurrencyConfigTabWidget> createState() =>
      _CurrencyConfigTabWidgetState();
}

class _CurrencyConfigTabWidgetState extends State<CurrencyConfigTabWidget> {
  final _service = PaymentSettingsService.instance;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _currencies = [];

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currencies = await _service.getCurrencySettings();
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            SizedBox(height: 2.h),
            Text('Failed to load currencies',
                style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: _loadCurrencies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCurrencies,
      child: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          Text(
            'Currency Exchange Rates & Settings',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2.h),
          ..._currencies.map((currency) => _buildCurrencyCard(currency)),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(Map<String, dynamic> currency) {
    final isActive = currency['is_active'] ?? false;
    final symbol = currency['symbol'] ?? '';
    final code = currency['currency_code'] ?? '';
    final rate = currency['exchange_rate_to_usd'] ?? 0.0;
    final fee = currency['conversion_fee_percentage'] ?? 0.0;
    final minAmount = currency['min_transaction_amount'] ?? 0.0;
    final maxAmount = currency['max_transaction_amount'] ?? 0.0;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withAlpha(26)
                        : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '1 USD = $rate $code',
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    // Handle toggle
                  },
                  activeThumbColor: const Color(0xFF10B981),
                ),
              ],
            ),
            Divider(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip('Fee', '$fee%', Icons.percent),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildInfoChip(
                      'Min', '$symbol$minAmount', Icons.arrow_downward),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildInfoChip(
                      'Max', '$symbol$maxAmount', Icons.arrow_upward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
