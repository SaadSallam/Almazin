import 'package:flutter/material.dart';

import '../../core/responsive/responsive_context.dart';
import 'app_search_field.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showTabletSidebarToggle = false,
    this.tabletSidebarExpanded = true,
    this.onTabletSidebarToggle,
    this.showDesktopSearch = false,
  });

  final String title;
  final List<Widget> actions;
  final bool showTabletSidebarToggle;
  final bool tabletSidebarExpanded;
  final VoidCallback? onTabletSidebarToggle;
  final bool showDesktopSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

    return AppBar(
      titleSpacing: 16,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
      ),
      actions: [
        if (showDesktopSearch && isDesktop)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8, top: 8, bottom: 8),
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
        ...actions,
      ],
    );
  }
}
