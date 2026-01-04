import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CurrencySelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> currencies;
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;

  const CurrencySelectorWidget({
    Key? key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  }) : super(key: key);

  String _getCurrencyFlag(String currencyCode) {
    const flags = {
      'USD': '🇺🇸',
      'INR': '🇮🇳',
      'EURO': '🇪🇺',
      'GBP': '🇬🇧',
    };
    return flags[currencyCode] ?? '💰';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
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
          Text(
            'Select Currency',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: currencies.length,
              separatorBuilder: (_, __) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final code = currency['currency_code'] as String;
                final isSelected = code == selectedCurrency;
                final exchangeRate = currency['exchange_rate_to_usd'] as double;

                return GestureDetector(
                  onTap: () => onCurrencyChanged(code),
                  child: Container(
                    width: 20.w,
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getCurrencyFlag(code),
                          style: TextStyle(fontSize: 24.sp),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          code,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '1 = \$${exchangeRate.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color:
                                isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
