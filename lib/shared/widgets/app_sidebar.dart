import 'package:flutter/material.dart';

import '../../core/navigation/app_nav.dart';
import '../../core/theme/theme_tokens_x.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.width,
    required this.expanded,
    required this.selectedPath,
    required this.onDestinationSelected,
  });

  final double width;
  final bool expanded;
  final String selectedPath;
  final ValueChanged<String> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.almazinTokens;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        left: false,
        right: false,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: scheme.surface,
            border: BorderDirectional(
              start: BorderSide(color: tokens.divider.withValues(alpha: 0.55)),
            ),
            boxShadow: [
              BoxShadow(
                color: tokens.shadow.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(-6, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.local_cafe, color: scheme.primary, size: 26),
                      if (expanded) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'المازن',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppNavItem.main.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = AppNavItem.main[index];
                      final active = isNavPathActive(selectedPath, item.path);
                      return _SidebarDestinationTile(
                        expanded: expanded,
                        active: active,
                        icon: item.icon,
                        label: item.label,
                        onTap: () => onDestinationSelected(item.path),
                      );
                    },
                  ),
                ),
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                    child: Text(
                      'Almazin App',
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.selectedPath,
    required this.onDestinationSelected,
  });

  final String selectedPath;
  final ValueChanged<String> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Row(
                  children: [
                    Icon(Icons.local_cafe, color: scheme.primary, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'المازن',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: AppNavItem.main.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = AppNavItem.main[index];
                    final active = isNavPathActive(selectedPath, item.path);
                    return _SidebarDestinationTile(
                      expanded: true,
                      active: active,
                      icon: item.icon,
                      label: item.label,
                      onTap: () {
                        Navigator.of(context).maybePop();
                        onDestinationSelected(item.path);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarDestinationTile extends StatefulWidget {
  const _SidebarDestinationTile({
    required this.expanded,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool expanded;
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SidebarDestinationTile> createState() => _SidebarDestinationTileState();
}

class _SidebarDestinationTileState extends State<_SidebarDestinationTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.almazinTokens;

    final Color bg = widget.active
        ? scheme.primary.withValues(alpha: 0.12)
        : _hovering
            ? scheme.primary.withValues(alpha: 0.06)
            : Colors.transparent;

    final Color fg = widget.active ? scheme.primary : scheme.onSurface;

    final borderColor = widget.active
        ? scheme.primary.withValues(alpha: 0.35)
        : tokens.divider.withValues(alpha: 0.25);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: widget.active
              ? [
                  BoxShadow(
                    color: tokens.shadow.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                    spreadRadius: -10,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            splashColor: scheme.primary.withValues(alpha: 0.10),
            hoverColor: scheme.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.expanded ? 12 : 10,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: fg, size: 22),
                  if (widget.expanded) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: fg,
                          fontWeight: widget.active ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
