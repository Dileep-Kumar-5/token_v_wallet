import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_icon_widget.dart';

/// Custom Bottom Navigation Bar Widget
///
/// Provides consistent bottom navigation across the app with three tabs:
/// - Home (Wallet Dashboard)
/// - Transactions (Transaction History)
/// - Profile (User Profile)
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: theme.textTheme.bodySmall,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: currentIndex == 0 ? 'home' : 'home_outlined',
            size: 24,
            color: currentIndex == 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: currentIndex == 1 ? 'receipt_long' : 'receipt_long',
            size: 24,
            color: currentIndex == 1
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: currentIndex == 2 ? 'person' : 'person_outline',
            size: 24,
            color: currentIndex == 2
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
