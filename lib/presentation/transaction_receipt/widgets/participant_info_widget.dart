import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Participant Info Widget
///
/// Displays transaction participants with avatars, names, and wallet addresses
class ParticipantInfoWidget extends StatelessWidget {
  final String contactName;
  final String contactAvatar;
  final String semanticLabel;
  final String type;

  const ParticipantInfoWidget({
    super.key,
    required this.contactName,
    required this.contactAvatar,
    required this.semanticLabel,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Participants',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          // From Section
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  type == 'sent' ? 'You' : contactName[0],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      type == 'sent' ? 'You' : contactName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 8)}...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Arrow Indicator
          Center(
            child: CustomIconWidget(
              iconName: 'arrow_downward',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),

          SizedBox(height: 2.h),

          // To Section
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: type == 'received' && contactAvatar.isNotEmpty
                    ? CachedNetworkImageProvider(contactAvatar)
                    : null,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: type == 'sent' && contactAvatar.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: contactAvatar,
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          errorWidget: (context, url, error) => Text(
                            contactName[0],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        type == 'received' ? 'You' : contactName[0],
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      type == 'received' ? 'You' : contactName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 8)}...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
