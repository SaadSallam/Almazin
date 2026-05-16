import 'package:flutter/material.dart';

import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_tokens_x.dart';

/// Premium sidebar component inspired by HeroUI Uber theme
/// Clean, professional desktop navigation with branded logo
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
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.almazinTokens;

    return Material(
      color: tokens.surfaceDefault,
      child: SafeArea(
        left: false,
        right: false,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: tokens.surfaceDefault,
            border: BorderDirectional(
              start: BorderSide(color: tokens.divider.withValues(alpha: 0.4)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.radiusSm,
                        child: Image.asset(
                          'assets/icon_app.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (expanded) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'المازن',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppNavItem.main.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
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
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    child: Text(
                      'Almazin App',
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: tokens.textTertiary,
                        fontSize: 11,
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
  State<_SidebarDestinationTile> createState() =>
      _SidebarDestinationTileState();
}

class _SidebarDestinationTileState extends State<_SidebarDestinationTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.almazinTokens;

    final Color bg = widget.active
        ? tokens.surfaceActive
        : _hovering
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
        : Colors.transparent;

    final Color fg = widget.active ? scheme.primary : tokens.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.radiusMd,
          border: widget.active
              ? Border.all(color: scheme.primary.withValues(alpha: 0.15))
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.radiusMd,
            onTap: widget.onTap,
            splashColor: scheme.primary.withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.expanded ? 12 : 10,
                vertical: 10,
              ),
              child: Row(
                children: [
                  // Active indicator dot
                  if (widget.active && widget.expanded) ...[
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(widget.icon, color: fg, size: 20),
                  if (widget.expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: fg,
                          fontWeight: widget.active
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
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
