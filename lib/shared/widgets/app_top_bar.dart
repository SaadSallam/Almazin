import 'package:flutter/material.dart';

import '../../core/responsive/responsive_context.dart';
import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_spacing.dart';
import 'app_search_field.dart';

/// Premium top bar component inspired by HeroUI Uber theme
/// Clean header with proper spacing and desktop optimization
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.showTabletSidebarToggle = false,
    this.tabletSidebarExpanded = true,
    this.onTabletSidebarToggle,
    this.showDesktopSearch = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool showTabletSidebarToggle;
  final bool tabletSidebarExpanded;
  final VoidCallback? onTabletSidebarToggle;
  final bool showDesktopSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;
    final isDesktop = context.isDesktop;

    return AppBar(
      titleSpacing: AppSpacing.lg,
      leading: leading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
      ),
      actions: [
        if (showDesktopSearch && isDesktop)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: SizedBox(
              width: 320,
              child: AppSearchField(
                dense: true,
                onChanged: (_) {},
              ),
            ),
          ),
        if (showTabletSidebarToggle && context.isTablet)
          IconButton(
            tooltip: tabletSidebarExpanded ? 'طي الشريط' : 'توسيع الشريط',
            onPressed: onTabletSidebarToggle,
            icon: Icon(
              tabletSidebarExpanded
                  ? Icons.view_sidebar_outlined
                  : Icons.view_agenda_outlined,
            ),
          ),
        ...actions.map((action) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: action,
            )),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
