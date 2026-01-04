import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for searching and selecting recipients
class RecipientSearchWidget extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function(Map<String, dynamic>) onRecipientSelected;

  const RecipientSearchWidget({
    super.key,
    required this.users,
    required this.onRecipientSelected,
  });

  @override
  State<RecipientSearchWidget> createState() => _RecipientSearchWidgetState();
}

class _RecipientSearchWidgetState extends State<RecipientSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredUsers = widget.users;
      } else {
        _filteredUsers = widget.users.where((user) {
          final name = (user["name"] as String).toLowerCase();
          final username = (user["username"] as String).toLowerCase();
          final email = (user["email"] as String).toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              username.contains(searchLower) ||
              email.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or search for a user',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        // Search bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Search by name, username, or email',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _filterUsers('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ),

        SizedBox(height: 2.h),

        // Search results
        _filteredUsers.isEmpty
            ? _buildEmptyState(theme)
            : _buildSearchResults(theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'person_search',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            _isSearching ? 'No users found' : 'Start typing to search',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isSearching) ...[
            SizedBox(height: 1.h),
            Text(
              'Try searching with a different name or email',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 40.h,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _filteredUsers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildUserTile(user, theme);
        },
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, ThemeData theme) {
    return InkWell(
      onTap: () => widget.onRecipientSelected(user),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CustomImageWidget(
                imageUrl: user["avatar"] ?? "",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                semanticLabel: user["semanticLabel"] ?? "User avatar",
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["name"] ?? "",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user["username"] ?? "",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
