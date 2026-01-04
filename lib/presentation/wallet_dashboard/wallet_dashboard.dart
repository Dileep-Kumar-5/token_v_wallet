import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/balance_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_transactions_widget.dart';

/// Wallet Dashboard Screen
///
/// Primary tab in bottom navigation providing secure overview of Token V credits
/// Features: Balance display with privacy toggle, quick actions, recent transactions
/// Implements pull-to-refresh, swipeable transaction cards, and biometric security
class WalletDashboard extends StatefulWidget {
  const WalletDashboard({super.key});

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard>
    with SingleTickerProviderStateMixin {
  // Current tab index for bottom navigation
  int _currentIndex = 0;

  // Balance visibility toggle
  bool _isBalanceVisible = true;

  // Loading state for pull-to-refresh
  bool _isRefreshing = false;

  // Mock user balance
  double _balance = 1250.75;

  // Mock recent transactions
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": "txn_001",
      "type": "sent",
      "contact": "Sarah Johnson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0364c46-1763300699786.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue shirt",
      "amount": -50.00,
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "completed"
    },
    {
      "id": "txn_002",
      "type": "received",
      "contact": "Michael Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_19b9f856b-1763296945059.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses",
      "amount": 125.50,
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "status": "completed"
    },
    {
      "id": "txn_003",
      "type": "sent",
      "contact": "Emma Williams",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1453e1878-1763300003100.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair and a friendly smile",
      "amount": -75.25,
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "completed"
    },
    {
      "id": "txn_004",
      "type": "received",
      "contact": "James Rodriguez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_18823495d-1763293949341.png",
      "semanticLabel":
          "Profile photo of a man with dark hair wearing a casual t-shirt",
      "amount": 200.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "status": "completed"
    },
    {
      "id": "txn_005",
      "type": "sent",
      "contact": "Olivia Martinez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f1d2e603-1763296333785.png",
      "semanticLabel":
          "Profile photo of a woman with curly hair wearing professional attire",
      "amount": -30.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "status": "completed"
    },
  ];

  // Animation controller for refresh
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isRefreshing = false);
    _refreshController.reverse();

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Balance updated',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Toggle balance visibility
  void _toggleBalanceVisibility() {
    setState(() => _isBalanceVisible = !_isBalanceVisible);
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    // Navigate to appropriate screen
    switch (index) {
      case 0:
        // Already on wallet dashboard
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/transaction-history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile-screen');
        break;
    }
  }

  /// Show balance options menu
  void _showBalanceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'file_download',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Export Statement',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Statement export feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Set Spending Limits',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Spending limits feature coming soon')),
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Token V Wallet',
        variant: CustomAppBarVariant.centered,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifications feature coming soon')),
              );
            },
            tooltip: 'Notifications',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SSL Security Badge
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'lock',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Secure Connection',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Balance Card with long-press gesture
              GestureDetector(
                onLongPress: _showBalanceOptions,
                child: BalanceCardWidget(
                  balance: _balance,
                  isVisible: _isBalanceVisible,
                  onToggleVisibility: _toggleBalanceVisibility,
                  isRefreshing: _isRefreshing,
                ),
              ),

              SizedBox(height: 3.h),

              // Quick Actions
              QuickActionsWidget(
                onSendCredits: () {
                  Navigator.pushNamed(context, '/send-credits');
                },
                onRequestCredits: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Request credits feature coming soon')),
                  );
                },
                onViewHistory: () {
                  Navigator.pushNamed(context, '/transaction-history');
                },
              ),

              SizedBox(height: 3.h),

              // Recent Transactions Section
              _recentTransactions.isEmpty
                  ? EmptyStateWidget(
                      onSendCredits: () {
                        Navigator.pushNamed(context, '/send-credits');
                      },
                    )
                  : RecentTransactionsWidget(
                      transactions: _recentTransactions,
                      onTransactionTap: (transaction) {
                        // Navigate to transaction details
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Transaction details: ${transaction["id"]}'),
                          ),
                        );
                      },
                      onSendAgain: (transaction) {
                        Navigator.pushNamed(
                          context,
                          '/send-credits',
                          arguments: {'recipient': transaction["contact"]},
                        );
                      },
                      onRequestFrom: (transaction) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Request from ${transaction["contact"]}'),
                          ),
                        );
                      },
                    ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/send-credits');
        },
        icon: CustomIconWidget(
          iconName: 'send',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Send',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
