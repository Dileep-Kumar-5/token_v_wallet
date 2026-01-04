import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/activity_item_widget.dart';
import './widgets/admin_tab_bar_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_button_widget.dart';

/// Admin Dashboard Screen
///
/// Provides comprehensive system oversight with user management and credit
/// administration capabilities optimized for mobile supervision.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 0;
  int _currentTabIndex = 0;
  late TabController _tabController;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock data for metrics
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Active Users",
      "value": "1,247",
      "change": "+12%",
      "isPositive": true,
      "icon": "people",
      "color": Color(0xFF4A90A4),
    },
    {
      "title": "Daily Transactions",
      "value": "3,892",
      "change": "+8%",
      "isPositive": true,
      "icon": "swap_horiz",
      "color": Color(0xFF2ECC71),
    },
    {
      "title": "System Balance",
      "value": "\$487,234",
      "change": "+15%",
      "isPositive": true,
      "icon": "account_balance_wallet",
      "color": Color(0xFF1B365D),
    },
    {
      "title": "Pending Issues",
      "value": "23",
      "change": "-5%",
      "isPositive": true,
      "icon": "warning",
      "color": Color(0xFFF39C12),
    },
  ];

  // Mock data for quick actions
  final List<Map<String, dynamic>> _quickActions = [
    {
      "title": "Credit User",
      "icon": "add_circle",
      "color": Color(0xFF4A90A4),
      "route": "/send-credits",
    },
    {
      "title": "Freeze User",
      "icon": "block",
      "color": Color(0xFFE74C3C),
      "route": null,
    },
    {
      "title": "Pending Txns",
      "icon": "pending_actions",
      "color": Color(0xFFF39C12),
      "route": "/transaction-history",
    },
    {
      "title": "Generate Report",
      "icon": "assessment",
      "color": Color(0xFF2ECC71),
      "route": null,
    },
  ];

  // Mock data for recent activity
  final List<Map<String, dynamic>> _recentActivity = [
    {
      "id": "ACT001",
      "type": "registration",
      "title": "New User Registration",
      "description": "Sarah Johnson registered successfully",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "severity": "info",
      "userEmail": "sarah.johnson@example.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0364c46-1763300699786.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue shirt",
    },
    {
      "id": "ACT002",
      "type": "transaction",
      "title": "Large Transaction Alert",
      "description": "Michael Chen sent \$5,000 to Emma Wilson",
      "timestamp": DateTime.now().subtract(Duration(minutes: 12)),
      "severity": "warning",
      "amount": "\$5,000",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a gray suit",
    },
    {
      "id": "ACT003",
      "type": "alert",
      "title": "System Alert",
      "description": "Multiple failed login attempts detected for account",
      "timestamp": DateTime.now().subtract(Duration(minutes: 18)),
      "severity": "critical",
      "userEmail": "john.doe@example.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13a5b94f8-1763295945028.png",
      "semanticLabel":
          "Profile photo of a man with short blonde hair wearing a white t-shirt",
    },
    {
      "id": "ACT004",
      "type": "transaction",
      "title": "Transaction Completed",
      "description": "Lisa Anderson received \$250 from David Brown",
      "timestamp": DateTime.now().subtract(Duration(minutes: 25)),
      "severity": "info",
      "amount": "\$250",
      "avatar": "https://images.unsplash.com/photo-1487613647282-7bd9d161e688",
      "semanticLabel":
          "Profile photo of a woman with curly red hair wearing a green sweater",
    },
    {
      "id": "ACT005",
      "type": "registration",
      "title": "New User Registration",
      "description": "Robert Martinez registered successfully",
      "timestamp": DateTime.now().subtract(Duration(minutes: 32)),
      "severity": "info",
      "userEmail": "robert.martinez@example.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11f4a03f8-1763294742899.png",
      "semanticLabel":
          "Profile photo of a man with short dark hair and a beard wearing a black shirt",
    },
    {
      "id": "ACT006",
      "type": "alert",
      "title": "Account Frozen",
      "description": "User account frozen due to suspicious activity",
      "timestamp": DateTime.now().subtract(Duration(minutes: 45)),
      "severity": "critical",
      "userEmail": "suspicious.user@example.com",
      "avatar": "https://images.unsplash.com/photo-1729858207092-c0da353d44d9",
      "semanticLabel":
          "Profile photo of a woman with short black hair wearing a red jacket",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleQuickAction(Map<String, dynamic> action) {
    if (action["route"] != null) {
      Navigator.pushNamed(context, action["route"] as String);
    } else {
      // Show biometric confirmation dialog
      _showBiometricConfirmation(action["title"] as String);
    }
  }

  void _showBiometricConfirmation(String actionTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action'),
        content: Text('Biometric authentication required for: $actionTitle'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$actionTitle action confirmed')),
              );
            },
            child: Text('Authenticate'),
          ),
        ],
      ),
    );
  }

  void _handleActivityAction(Map<String, dynamic> activity, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Activity'),
        content: Text('${activity["title"]}\n\n${activity["description"]}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$action action completed')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Users & Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or transaction ID',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 1.h),
                  _buildRecentSearchItem('sarah.johnson@example.com'),
                  _buildRecentSearchItem('Transaction #TXN12345'),
                  _buildRecentSearchItem('Michael Chen'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String searchTerm) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CustomIconWidget(
        iconName: 'history',
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(searchTerm),
      trailing: CustomIconWidget(
        iconName: 'north_west',
        color: theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: () {
        _searchController.text = searchTerm;
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Options',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Date Range',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildFilterChip('Today'),
                      _buildFilterChip('Last 7 Days'),
                      _buildFilterChip('Last 30 Days'),
                      _buildFilterChip('Custom'),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Transaction Amount',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildFilterChip('Under \$100'),
                      _buildFilterChip('\$100 - \$1,000'),
                      _buildFilterChip('Over \$1,000'),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'User Status',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildFilterChip('Active'),
                      _buildFilterChip('Frozen'),
                      _buildFilterChip('Pending'),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filters applied')),
                        );
                      },
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        variant: CustomAppBarVariant.centered,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showSearchBottomSheet,
            tooltip: 'Search',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // Admin Badge Indicator
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'admin_panel_settings',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Administrator Mode',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
            SliverToBoxAdapter(
              child: AdminTabBarWidget(
                tabController: _tabController,
                currentIndex: _currentTabIndex,
              ),
            ),

            // Tab Content
            SliverToBoxAdapter(
              child: SizedBox(
                height: 75.h,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildUsersTab(),
                    _buildTransactionsTab(),
                    _buildAnalyticsTab(),
                    _buildReportsTab(),
                  ],
                ),
              ),
            ),
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

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Cards
          Text(
            'Key Metrics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.4,
            ),
            itemCount: _metricsData.length,
            itemBuilder: (context, index) {
              return MetricsCardWidget(
                data: _metricsData[index],
              );
            },
          ),

          SizedBox(height: 3.h),

          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.8,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              return QuickActionButtonWidget(
                action: _quickActions[index],
                onTap: () => _handleQuickAction(_quickActions[index]),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transaction-history');
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Critical Alerts
          ..._recentActivity
              .where((activity) => activity["severity"] == "critical")
              .map((activity) => Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error',
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Critical Alert',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          activity["title"] as String,
                          style: theme.textTheme.titleSmall,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          activity["description"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleActivityAction(
                                    activity, 'Investigate'),
                                child: Text('Investigate'),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleActivityAction(
                                    activity, 'Take Action'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                ),
                                child: Text('Take Action'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),

          // Activity List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivity
                .where((a) => a["severity"] != "critical")
                .length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final activities = _recentActivity
                  .where((a) => a["severity"] != "critical")
                  .toList();
              return ActivityItemWidget(
                activity: activities[index],
                onInvestigate: () =>
                    _handleActivityAction(activities[index], 'Investigate'),
                onApprove: () =>
                    _handleActivityAction(activities[index], 'Approve'),
                onDeny: () => _handleActivityAction(activities[index], 'Deny'),
                onContact: () =>
                    _handleActivityAction(activities[index], 'Contact'),
              );
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'people',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'User Management',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              'View and manage all registered users, freeze/unfreeze accounts, and monitor user activity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User management feature coming soon')),
                );
              },
              icon: CustomIconWidget(
                iconName: 'manage_accounts',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Manage Users'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Transaction Monitoring',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              'Monitor all transactions, review pending transfers, and investigate suspicious activity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/transaction-history');
              },
              icon: CustomIconWidget(
                iconName: 'history',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('View Transactions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Ledger Analytics',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              'View comprehensive blockchain-based transaction verification, anomaly detection, and balance reconciliation reports.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ledger-analytics-panel');
              },
              icon: CustomIconWidget(
                iconName: 'security',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Open Analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'assessment',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Reports & Analytics',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              'Generate comprehensive reports, view analytics, and export data for analysis.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports feature coming soon')),
                );
              },
              icon: CustomIconWidget(
                iconName: 'download',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
