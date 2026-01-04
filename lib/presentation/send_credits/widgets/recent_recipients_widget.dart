import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget for displaying recent recipients as quick selection chips
class RecentRecipientsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recipients;
  final Function(Map<String, dynamic>) onRecipientSelected;

  const RecentRecipientsWidget({
    super.key,
    required this.recipients,
    required this.onRecipientSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent recipients',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recipients.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final recipient = recipients[index];
              return _buildRecipientChip(recipient, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientChip(Map<String, dynamic> recipient, ThemeData theme) {
    return InkWell(
      onTap: () => onRecipientSelected(recipient),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 20.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CustomImageWidget(
                imageUrl: recipient["avatar"] ?? "",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                semanticLabel: recipient["semanticLabel"] ?? "Recipient avatar",
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              (recipient["name"] as String).split(' ')[0],
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
