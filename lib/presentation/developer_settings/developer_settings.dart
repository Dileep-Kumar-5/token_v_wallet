import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/payment_settings_service.dart';
import './widgets/country_settings_tab_widget.dart';
import './widgets/currency_config_tab_widget.dart';
import './widgets/release_management_tab_widget.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() =>
      _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = PaymentSettingsService.instance;
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _dashboardData = {
    'total_transactions': 0,
    'total_revenue': 0.0,
    'active_countries': 0,
    'active_currencies': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currencies = await _service.getCurrencySettings();
      final countries = await _service.getCountrySettings();

      setState(() {
        _dashboardData = {
          'active_currencies': currencies.length,
          'active_countries': countries.length,
          'total_transactions': 0,
          'total_revenue': 0.0,
        };
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Developer Settings',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Currency Config'),
            Tab(text: 'Country Settings'),
            Tab(text: 'Release Management'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 2.h),
                  Text('Loading settings...',
                      style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[400]),
                      SizedBox(height: 2.h),
                      Text(
                        'Error loading settings',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton.icon(
                        onPressed: _loadDashboardData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.5.h),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildDashboardOverview(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          CurrencyConfigTabWidget(),
                          CountrySettingsTabWidget(),
                          ReleaseManagementTabWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDashboardOverview() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Currencies',
                  _dashboardData['active_currencies'].toString(),
                  Icons.monetization_on,
                  const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Active Countries',
                  _dashboardData['active_countries'].toString(),
                  Icons.public,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
