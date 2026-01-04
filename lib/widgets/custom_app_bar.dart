import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Variants for the custom app bar
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with centered title
  centered,

  /// App bar with large title (for scrollable content)
  large,

  /// Transparent app bar (for overlays)
  transparent,

  /// App bar with search functionality
  search,
}

/// A custom app bar widget optimized for mobile fintech applications.
///
/// This widget provides a clean, professional app bar with multiple variants
/// to support different screen contexts. It maintains consistent styling
/// across the application while providing flexibility for specific use cases.
///
/// Features:
/// - Multiple variants (standard, centered, large, transparent, search)
/// - Automatic status bar styling
/// - Optional leading and action buttons
/// - Smooth transitions and animations
/// - Accessibility support
/// - Platform-adaptive styling
///
/// Example usage:
/// ```dart
/// Scaffold(
///   appBar: CustomAppBar(
///     title: 'Wallet Dashboard',
///     variant: CustomAppBarVariant.centered,
///     actions: [
///       IconButton(
///         icon: Icon(Icons.notifications_outlined),
///         onPressed: () {},
///       ),
///     ],
///   ),
///   body: YourContent(),
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// The variant of the app bar
  final CustomAppBarVariant variant;

  /// Optional leading widget (typically a back button or menu icon)
  final Widget? leading;

  /// Optional action widgets (typically icon buttons)
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// Optional subtitle for the app bar
  final String? subtitle;

  /// Optional background color override
  final Color? backgroundColor;

  /// Optional elevation override
  final double? elevation;

  /// Callback for the leading button
  final VoidCallback? onLeadingPressed;

  /// Whether to show a bottom border
  final bool showBottomBorder;

  /// Creates a custom app bar
  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.subtitle,
    this.backgroundColor,
    this.elevation,
    this.onLeadingPressed,
    this.showBottomBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    // Determine if we should show a back button
    final canPop = Navigator.of(context).canPop();
    final shouldShowLeading = automaticallyImplyLeading && canPop;

    // Build the appropriate app bar based on variant
    switch (variant) {
      case CustomAppBarVariant.standard:
        return _buildStandardAppBar(
          context,
          theme,
          colorScheme,
          appBarTheme,
          shouldShowLeading,
        );
      case CustomAppBarVariant.centered:
        return _buildCenteredAppBar(
          context,
          theme,
          colorScheme,
          appBarTheme,
          shouldShowLeading,
        );
      case CustomAppBarVariant.large:
        return _buildLargeAppBar(
          context,
          theme,
          colorScheme,
          appBarTheme,
          shouldShowLeading,
        );
      case CustomAppBarVariant.transparent:
        return _buildTransparentAppBar(
          context,
          theme,
          colorScheme,
          appBarTheme,
          shouldShowLeading,
        );
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(
          context,
          theme,
          colorScheme,
          appBarTheme,
          shouldShowLeading,
        );
    }
  }

  /// Builds a standard app bar
  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppBarThemeData appBarTheme,
    bool shouldShowLeading,
  ) {
    return AppBar(
      leading: _buildLeading(context, shouldShowLeading),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: appBarTheme.titleTextStyle,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      centerTitle: false,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      bottom: showBottomBorder ? _buildBottomBorder(colorScheme) : null,
    );
  }

  /// Builds a centered app bar
  Widget _buildCenteredAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppBarThemeData appBarTheme,
    bool shouldShowLeading,
  ) {
    return AppBar(
      leading: _buildLeading(context, shouldShowLeading),
      title: Text(
        title,
        style: appBarTheme.titleTextStyle,
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      centerTitle: true,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      bottom: showBottomBorder ? _buildBottomBorder(colorScheme) : null,
    );
  }

  /// Builds a large app bar (for scrollable content)
  Widget _buildLargeAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppBarThemeData appBarTheme,
    bool shouldShowLeading,
  ) {
    return AppBar(
      leading: _buildLeading(context, shouldShowLeading),
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      centerTitle: false,
      toolbarHeight: 72,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      bottom: showBottomBorder ? _buildBottomBorder(colorScheme) : null,
    );
  }

  /// Builds a transparent app bar
  Widget _buildTransparentAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppBarThemeData appBarTheme,
    bool shouldShowLeading,
  ) {
    return AppBar(
      leading: _buildLeading(context, shouldShowLeading),
      title: Text(
        title,
        style: appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
    );
  }

  /// Builds a search app bar
  Widget _buildSearchAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppBarThemeData appBarTheme,
    bool shouldShowLeading,
  ) {
    return AppBar(
      leading: _buildLeading(context, shouldShowLeading),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: title,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      bottom: showBottomBorder ? _buildBottomBorder(colorScheme) : null,
    );
  }

  /// Builds the leading widget
  Widget? _buildLeading(BuildContext context, bool shouldShowLeading) {
    if (leading != null) {
      return leading;
    }

    if (shouldShowLeading) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Builds the bottom border
  PreferredSize _buildBottomBorder(ColorScheme colorScheme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        color: colorScheme.outline.withValues(alpha: 0.2),
      ),
    );
  }

  /// Gets the system overlay style based on theme brightness
  SystemUiOverlayStyle _getSystemOverlayStyle(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomAppBarVariant.large:
        return const Size.fromHeight(72);
      default:
        return const Size.fromHeight(56);
    }
  }
}

/// A sliver app bar variant for scrollable content with collapse behavior
class CustomSliverAppBar extends StatelessWidget {
  /// The title to display in the app bar
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Optional leading widget
  final Widget? leading;

  /// Optional action widgets
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// The expanded height of the app bar
  final double expandedHeight;

  /// Whether the app bar should float
  final bool floating;

  /// Whether the app bar should pin when collapsed
  final bool pinned;

  /// Whether the app bar should snap
  final bool snap;

  /// Optional background color
  final Color? backgroundColor;

  /// Creates a custom sliver app bar
  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.expandedHeight = 120,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    return SliverAppBar(
      leading: leading,
      title: Text(
        title,
        style: appBarTheme.titleTextStyle,
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: appBarTheme.elevation,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      snap: snap,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: theme.brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}
