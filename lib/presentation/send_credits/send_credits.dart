import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/amount_input_widget.dart';
import './widgets/recent_recipients_widget.dart';
import './widgets/recipient_search_widget.dart';
import './widgets/transaction_preview_widget.dart';

/// Send Credits Screen
/// Enables peer-to-peer Token V transfers with recipient search and amount validation
class SendCredits extends StatefulWidget {
  const SendCredits({super.key});

  @override
  State<SendCredits> createState() => _SendCreditsState();
}

class _SendCreditsState extends State<SendCredits> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Screen state management
  int _currentStep = 0; // 0: Search, 1: Amount, 2: Preview
  Map<String, dynamic>? _selectedRecipient;
  double _amount = 0.0;
  bool _isProcessing = false;
  bool _showSuccess = false;
  String _transactionId = '';

  // Mock current user balance
  final double _currentBalance = 1250.50;

  // Mock user data for search results
  final List<Map<String, dynamic>> _allUsers = [
    {
      "id": "user_001",
      "name": "Sarah Johnson",
      "username": "@sarahj",
      "email": "sarah.johnson@email.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0364c46-1763300699786.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue shirt"
    },
    {
      "id": "user_002",
      "name": "Michael Chen",
      "username": "@mchen",
      "email": "michael.chen@email.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a gray sweater"
    },
    {
      "id": "user_003",
      "name": "Emily Rodriguez",
      "username": "@emilyrod",
      "email": "emily.rodriguez@email.com",
      "avatar": "https://images.unsplash.com/photo-1590926624801-d54a104b85f5",
      "semanticLabel":
          "Profile photo of a woman with curly dark hair wearing a red top"
    },
    {
      "id": "user_004",
      "name": "David Kim",
      "username": "@davidk",
      "email": "david.kim@email.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f2746db7-1763296313857.png",
      "semanticLabel":
          "Profile photo of a man with short dark hair wearing a black jacket"
    },
    {
      "id": "user_005",
      "name": "Jessica Martinez",
      "username": "@jessicam",
      "email": "jessica.martinez@email.com",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e5c54426-1763299106654.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair wearing a white blouse"
    },
  ];

  // Recent recipients for quick selection
  final List<Map<String, dynamic>> _recentRecipients = [
    {
      "id": "user_001",
      "name": "Sarah Johnson",
      "username": "@sarahj",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0364c46-1763300699786.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue shirt"
    },
    {
      "id": "user_002",
      "name": "Michael Chen",
      "username": "@mchen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a gray sweater"
    },
    {
      "id": "user_003",
      "name": "Emily Rodriguez",
      "username": "@emilyrod",
      "avatar": "https://images.unsplash.com/photo-1590926624801-d54a104b85f5",
      "semanticLabel":
          "Profile photo of a woman with curly dark hair wearing a red top"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Send Credits',
        variant: CustomAppBarVariant.centered,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _showSuccess ? _buildSuccessScreen(theme) : _buildMainContent(theme),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return SafeArea(
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme),

          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _currentStep == 0
                      ? _buildRecipientSelection(theme)
                      : _currentStep == 1
                          ? _buildAmountInput(theme)
                          : _buildTransactionPreview(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Recipient', theme),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              color: _currentStep > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          _buildStepIndicator(1, 'Amount', theme),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              color: _currentStep > 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          _buildStepIndicator(2, 'Confirm', theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, ThemeData theme) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: isActive
              ? Center(
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                )
              : null,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who would you like to send credits to?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),

        // Recent recipients
        RecentRecipientsWidget(
          recipients: _recentRecipients,
          onRecipientSelected: (recipient) {
            setState(() {
              _selectedRecipient = recipient;
              _currentStep = 1;
            });
          },
        ),

        SizedBox(height: 3.h),

        // Search section
        RecipientSearchWidget(
          users: _allUsers,
          onRecipientSelected: (recipient) {
            setState(() {
              _selectedRecipient = recipient;
              _currentStep = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected recipient card
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CustomImageWidget(
                  imageUrl: _selectedRecipient?["avatar"] ?? "",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  semanticLabel:
                      _selectedRecipient?["semanticLabel"] ?? "User avatar",
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedRecipient?["name"] ?? "",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _selectedRecipient?["username"] ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _selectedRecipient = null;
                  });
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Amount input
        AmountInputWidget(
          currentBalance: _currentBalance,
          onAmountChanged: (amount) {
            setState(() {
              _amount = amount;
            });
          },
          onContinue: () {
            if (_amount > 0 && _amount <= _currentBalance) {
              setState(() {
                _currentStep = 2;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTransactionPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Transaction',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),

        TransactionPreviewWidget(
          recipient: _selectedRecipient!,
          amount: _amount,
          currentBalance: _currentBalance,
          onEdit: () {
            setState(() {
              _currentStep = 1;
            });
          },
        ),

        SizedBox(height: 4.h),

        // Send button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleSendCredits,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'lock',
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Send Now',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 2.h),

        // Security notice
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'You\'ll be asked to authenticate with biometrics before sending',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Transfer Successful!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'You sent \$${_amount.toStringAsFixed(2)} to ${_selectedRecipient?["name"]}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Transaction ID', _transactionId, theme),
                  Divider(height: 3.h),
                  _buildInfoRow('Date', _formatDate(DateTime.now()), theme),
                  Divider(height: 3.h),
                  _buildInfoRow('Status', 'Completed', theme),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSuccess = false;
                    _currentStep = 0;
                    _selectedRecipient = null;
                    _amount = 0.0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Send Another',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back to Dashboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendCredits() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Check biometric availability
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        // Authenticate with biometrics
        final authenticated = await _localAuth.authenticate(
          localizedReason:
              'Authenticate to send \$${_amount.toStringAsFixed(2)} to ${_selectedRecipient?["name"]}',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        if (!authenticated) {
          setState(() {
            _isProcessing = false;
          });
          _showErrorDialog('Authentication failed. Please try again.');
          return;
        }
      }

      // Simulate transaction processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate transaction ID
      _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _isProcessing = false;
        _showSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Transaction failed. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Error',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
