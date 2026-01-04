import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/ledger_analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/verification_card_widget.dart';
import './widgets/anomaly_card_widget.dart';
import './widgets/reconciliation_card_widget.dart';

/// Ledger Analytics Panel
///
/// Comprehensive blockchain-based transaction verification and anomaly detection
/// for Token V Wallet administrators
class LedgerAnalyticsPanel extends StatefulWidget {
  const LedgerAnalyticsPanel({super.key});

  @override
  State<LedgerAnalyticsPanel> createState() => _LedgerAnalyticsPanelState();
}

class _LedgerAnalyticsPanelState extends State<LedgerAnalyticsPanel> {
  final LedgerAnalyticsService _analyticsService = LedgerAnalyticsService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _verifications = [];
  List<Map<String, dynamic>> _anomalies = [];
  Map<String, dynamic>? _reconciliationData;
  String? _error;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verifications =
          await _analyticsService.getTransactionVerifications(limit: 100);
      final anomalies = await _analyticsService.detectAnomalies();
      final reconciliation = await _analyticsService.getBalanceReconciliation();

      setState(() {
        _verifications = verifications;
        _anomalies = anomalies;
        _reconciliationData = reconciliation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAnalyticsData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analytics data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Analytics Report'),
        content: Text(
            'Generate PDF report with cryptographic signatures for audit purposes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report generation started')),
              );
            },
            child: Text('Export PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ledger Analytics',
        variant: CustomAppBarVariant.centered,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : CustomScrollView(
                    slivers: [
                      // Security Badge
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.all(4.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'security',
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Blockchain Verification Active',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'All data derived from immutable ledger entries',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Transaction Verification Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Transaction Verification',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 1.h)),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return VerificationCardWidget(
                                verification: _verifications[index],
                              );
                            },
                            childCount: _verifications.take(10).length,
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                      // Anomaly Detection Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Anomaly Detection',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _anomalies.isEmpty
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_anomalies.length} Detected',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 1.h)),
                      _anomalies.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'check_circle',
                                        color: theme.colorScheme.primary,
                                        size: 48,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'No Anomalies Detected',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        'All transactions within normal patterns',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return AnomalyCardWidget(
                                      anomaly: _anomalies[index],
                                    );
                                  },
                                  childCount: _anomalies.length,
                                ),
                              ),
                            ),

                      SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                      // Balance Reconciliation Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Balance Reconciliation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 1.h)),
                      if (_reconciliationData != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: ReconciliationCardWidget(
                              reconciliationData: _reconciliationData!,
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                    ],
                  ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Failed to Load Analytics',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              _error ?? 'Unknown error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _loadAnalyticsData,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
