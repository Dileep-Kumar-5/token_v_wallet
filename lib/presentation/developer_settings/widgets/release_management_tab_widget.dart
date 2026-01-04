import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReleaseManagementTabWidget extends StatefulWidget {
  const ReleaseManagementTabWidget({super.key});

  @override
  State<ReleaseManagementTabWidget> createState() =>
      _ReleaseManagementTabWidgetState();
}

class _ReleaseManagementTabWidgetState
    extends State<ReleaseManagementTabWidget> {
  final List<Map<String, dynamic>> _featureFlags = [
    {
      'name': 'Credit Card Payments',
      'key': 'credit_card_payments',
      'enabled': true,
      'description': 'Allow users to pay with credit cards',
    },
    {
      'name': 'Bank Account Payouts',
      'key': 'bank_payouts',
      'enabled': true,
      'description': 'Enable bank account payout functionality',
    },
    {
      'name': 'Multi-Currency Support',
      'key': 'multi_currency',
      'enabled': true,
      'description': 'Support for USD, EUR, GBP, INR',
    },
    {
      'name': 'Regional Restrictions',
      'key': 'regional_restrictions',
      'enabled': false,
      'description': 'Block access from specific countries',
    },
  ];

  final Map<String, dynamic> _performanceMetrics = {
    'total_transactions': 1234,
    'successful_rate': 98.5,
    'avg_processing_time': 2.3,
    'error_rate': 1.5,
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Text(
          'Feature Flags',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2.h),
        ..._featureFlags.map((flag) => _buildFeatureFlagCard(flag)),
        SizedBox(height: 3.h),
        Text(
          'Performance Metrics',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2.h),
        _buildPerformanceCard(),
        SizedBox(height: 3.h),
        Text(
          'Deployment Actions',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2.h),
        _buildDeploymentActions(),
      ],
    );
  }

  Widget _buildFeatureFlagCard(Map<String, dynamic> flag) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flag['name'],
                    style:
                        TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    flag['description'],
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: flag['enabled'],
              onChanged: (value) {
                setState(() {
                  flag['enabled'] = value;
                });
              },
              activeThumbColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Transactions',
                    _performanceMetrics['total_transactions'].toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildMetricItem(
                    'Success Rate',
                    '${_performanceMetrics['successful_rate']}%',
                    Icons.check_circle,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Avg Process Time',
                    '${_performanceMetrics['avg_processing_time']}s',
                    Icons.timer,
                    const Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildMetricItem(
                    'Error Rate',
                    '${_performanceMetrics['error_rate']}%',
                    Icons.error_outline,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButton(
              'Export Configuration',
              Icons.download,
              const Color(0xFF3B82F6),
              () {
                // Handle export
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting configuration...')),
                );
              },
            ),
            SizedBox(height: 2.h),
            _buildActionButton(
              'Generate Compliance Report',
              Icons.description,
              const Color(0xFF10B981),
              () {
                // Handle report generation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Generating compliance report...')),
                );
              },
            ),
            SizedBox(height: 2.h),
            _buildActionButton(
              'Run Automated Tests',
              Icons.play_circle,
              const Color(0xFFF59E0B),
              () {
                // Handle test run
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Running automated tests...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
