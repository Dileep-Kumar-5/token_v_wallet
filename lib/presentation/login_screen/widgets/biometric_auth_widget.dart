import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Biometric authentication widget
///
/// Features:
/// - Platform-specific biometric icons (Face ID/Touch ID/Fingerprint)
/// - Biometric authentication trigger
/// - Visual feedback
/// - Accessibility support
class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const BiometricAuthWidget({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  /// Get biometric icon based on platform
  String _getBiometricIcon() {
    if (kIsWeb) {
      return 'fingerprint';
    }

    try {
      if (Platform.isIOS) {
        return 'face'; // Face ID icon for iOS
      } else {
        return 'fingerprint'; // Fingerprint for Android
      }
    } catch (e) {
      return 'fingerprint';
    }
  }

  /// Get biometric label based on platform
  String _getBiometricLabel() {
    if (kIsWeb) {
      return 'Biometric Login';
    }

    try {
      if (Platform.isIOS) {
        return 'Login with Face ID';
      } else {
        return 'Login with Fingerprint';
      }
    } catch (e) {
      return 'Biometric Login';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric button
        InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(4.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getBiometricIcon(),
                      size: 32,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _getBiometricLabel(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Quick and secure access',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
