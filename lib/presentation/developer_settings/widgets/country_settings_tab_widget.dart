import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/payment_settings_service.dart';

class CountrySettingsTabWidget extends StatefulWidget {
  const CountrySettingsTabWidget({super.key});

  @override
  State<CountrySettingsTabWidget> createState() =>
      _CountrySettingsTabWidgetState();
}

class _CountrySettingsTabWidgetState extends State<CountrySettingsTabWidget> {
  final _service = PaymentSettingsService.instance;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final countries = await _service.getCountrySettings();
      setState(() {
        _countries = countries;
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
            Text('Failed to load countries', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: _loadCountries,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCountries,
      child: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          Text(
            'Country Deployment Settings',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2.h),
          ..._countries.map((country) => _buildCountryCard(country)),
        ],
      ),
    );
  }

  Widget _buildCountryCard(Map<String, dynamic> country) {
    final isActive = country['is_active'] ?? false;
    final name = country['country_name'] ?? '';
    final code = country['country_code'] ?? '';
    final currency = country['default_currency'] ?? '';
    final status = country['regulatory_approval_status'] ?? 'pending';
    final bankingActive = country['banking_integration_active'] ?? false;
    final paymentMethods =
        List<String>.from(country['supported_payment_methods'] ?? []);

    Color statusColor;
    String statusText;
    switch (status) {
      case 'verified':
        statusColor = const Color(0xFF10B981);
        statusText = 'Verified';
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Pending';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

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
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    name,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  'Currency: $currency',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(77)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 10.sp, color: statusColor),
                  ),
                ),
              ],
            ),
            Divider(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    'Banking',
                    bankingActive ? 'Active' : 'Inactive',
                    bankingActive,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildStatusItem(
                    'Payment Methods',
                    '${paymentMethods.length} Types',
                    paymentMethods.isNotEmpty,
                  ),
                ),
              ],
            ),
            if (paymentMethods.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: paymentMethods
                    .map((method) => Chip(
                          label: Text(
                            method.replaceAll('_', ' '),
                            style: TextStyle(fontSize: 10.sp),
                          ),
                          backgroundColor: Colors.blue[50],
                          labelPadding: EdgeInsets.symmetric(horizontal: 1.w),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, bool isActive) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF10B981).withAlpha(26)
            : Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF10B981) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
