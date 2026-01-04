import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/transaction_card_widget.dart';
import './widgets/transaction_detail_modal_widget.dart';

/// Transaction History Screen
///
/// Provides comprehensive view of all Token V credit transactions with
/// filtering, search, and detailed transaction information.
class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  // Current tab index for bottom navigation
  int _currentIndex = 1;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedTypes = {'sent', 'received', 'pending'};
  double _minAmount = 0;
  double _maxAmount = 10000;

  // UI state
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  int _currentBottomNavIndex = 2; // History tab

  // Mock data for transactions
  final List<Map<String, dynamic>> _allTransactions = [
    {
      "id": "TXN001",
      "contactName": "Sarah Johnson",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0364c46-1763300699786.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue shirt",
      "type": "sent",
      "amount": 150.00,
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "completed",
      "note": "Lunch payment",
      "fees": 0.00,
    },
    {
      "id": "TXN002",
      "contactName": "Michael Chen",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_19b9f856b-1763296945059.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses",
      "type": "received",
      "amount": 250.00,
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "status": "completed",
      "note": "Project payment",
      "fees": 0.00,
    },
    {
      "id": "TXN003",
      "contactName": "Emily Rodriguez",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11b96b2f1-1763294850372.png",
      "semanticLabel": "Profile photo of a woman with curly dark hair smiling",
      "type": "sent",
      "amount": 75.50,
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "completed",
      "note": "Coffee meetup",
      "fees": 0.00,
    },
    {
      "id": "TXN004",
      "contactName": "David Kim",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f2746db7-1763296313857.png",
      "semanticLabel": "Profile photo of a man with short dark hair in a suit",
      "type": "received",
      "amount": 500.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "status": "completed",
      "note": "Freelance work",
      "fees": 0.00,
    },
    {
      "id": "TXN005",
      "contactName": "Jessica Martinez",
      "contactAvatar":
          "https://images.unsplash.com/photo-1624292001877-a371a30b9e27",
      "semanticLabel":
          "Profile photo of a woman with blonde hair wearing sunglasses",
      "type": "sent",
      "amount": 200.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "status": "pending",
      "note": "Event tickets",
      "fees": 0.00,
    },
    {
      "id": "TXN006",
      "contactName": "Robert Taylor",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1c8b652f2-1763293994171.png",
      "semanticLabel": "Profile photo of a man with gray hair and beard",
      "type": "received",
      "amount": 350.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 4)),
      "status": "completed",
      "note": "Consulting fee",
      "fees": 0.00,
    },
    {
      "id": "TXN007",
      "contactName": "Amanda Wilson",
      "contactAvatar":
          "https://images.unsplash.com/photo-1684961418110-fb5fe4201e16",
      "semanticLabel":
          "Profile photo of a woman with red hair wearing a green top",
      "type": "sent",
      "amount": 125.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "status": "completed",
      "note": "Gym membership",
      "fees": 0.00,
    },
    {
      "id": "TXN008",
      "contactName": "James Anderson",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1424c33d1-1763293939266.png",
      "semanticLabel":
          "Profile photo of a man with brown hair in casual attire",
      "type": "received",
      "amount": 180.00,
      "timestamp": DateTime.now().subtract(const Duration(days: 6)),
      "status": "completed",
      "note": "Shared expenses",
      "fees": 0.00,
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];
  DateTime? _lastUpdated;

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    // Navigate to appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/wallet-dashboard');
        break;
      case 1:
        // Already on transaction history
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile-screen');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
    _lastUpdated = DateTime.now();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Simulate loading more transactions
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  Future<void> _refreshTransactions() async {
    setState(() => _isRefreshing = true);

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Type filter
        if (!_selectedTypes.contains(transaction['type'] as String)) {
          return false;
        }

        // Amount filter
        final amount = transaction['amount'] as double;
        if (amount < _minAmount || amount > _maxAmount) {
          return false;
        }

        // Date filter
        if (_startDate != null && _endDate != null) {
          final timestamp = transaction['timestamp'] as DateTime;
          if (timestamp.isBefore(_startDate!) || timestamp.isAfter(_endDate!)) {
            return false;
          }
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final name = (transaction['contactName'] as String).toLowerCase();
          final id = (transaction['id'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();

          if (!name.contains(query) && !id.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        startDate: _startDate,
        endDate: _endDate,
        selectedTypes: _selectedTypes,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        onApply: (startDate, endDate, types, minAmount, maxAmount) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _selectedTypes = types;
            _minAmount = minAmount;
            _maxAmount = maxAmount;
          });
          _applyFilters();
        },
        onReset: () {
          setState(() {
            _startDate = null;
            _endDate = null;
            _selectedTypes = {'sent', 'received', 'pending'};
            _minAmount = 0;
            _maxAmount = 10000;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModalWidget(
        transaction: transaction,
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('View Details', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showTransactionDetail(transaction);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Download Receipt', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt downloaded')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'note_add',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Add Note', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Transaction History',
        variant: CustomAppBarVariant.centered,
        showBottomBorder: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter header
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: CustomIconWidget(
                            iconName: 'search',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: CustomIconWidget(
                                    iconName: 'clear',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _applyFilters();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: CustomIconWidget(
                        iconName: 'filter_list',
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
            ),

            // Last updated indicator
            if (_lastUpdated != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(_lastUpdated!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // Transaction list
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? EmptyStateWidget(
                      onStartSending: () {
                        Navigator.pushNamed(context, '/send-credits');
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTransactions,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount:
                            _filteredTransactions.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredTransactions.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          }

                          final transaction = _filteredTransactions[index];

                          return Slidable(
                            key: ValueKey(transaction['id']),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Send Again')),
                                    );
                                  },
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  icon: Icons.send,
                                  label: 'Send Again',
                                ),
                                if (transaction['type'] == 'sent')
                                  SlidableAction(
                                    onPressed: (context) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Request Return')),
                                      );
                                    },
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    foregroundColor:
                                        theme.colorScheme.onSecondary,
                                    icon: Icons.undo,
                                    label: 'Request',
                                  ),
                                SlidableAction(
                                  onPressed: (context) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Contact User')),
                                    );
                                  },
                                  backgroundColor: theme.colorScheme.tertiary,
                                  foregroundColor: theme.colorScheme.onTertiary,
                                  icon: Icons.person,
                                  label: 'Contact',
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Receipt Shared')),
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.share,
                                  label: 'Share',
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Issue Reported')),
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.report,
                                  label: 'Report',
                                ),
                              ],
                            ),
                            child: TransactionCardWidget(
                              transaction: transaction,
                              onTap: () => _showTransactionDetail(transaction),
                              onLongPress: () => _showContextMenu(transaction),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          _onBottomNavTap(index);
        },
      ),
    );
  }
}
