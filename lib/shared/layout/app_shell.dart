import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_nav.dart';
import '../../core/responsive/responsive_context.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_top_bar.dart';

/// Application chrome: RTL right rail, adaptive drawer, and top bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _tabletSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final title = appPageTitleForLocation(path);
    final router = GoRouter.of(context);
    final canPop = router.canPop();

    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final sidebarExpanded = isDesktop ? true : _tabletSidebarExpanded;
    final sidebarWidth = isMobile ? 0.0 : (sidebarExpanded ? 270.0 : 84.0);

    return Scaffold(
      drawer: isMobile
          ? AppNavigationDrawer(
              selectedPath: path,
              onDestinationSelected: (target) => context.go(target),
            )
          : null,
      appBar: AppTopBar(
        title: title,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                tooltip: 'رجوع',
                onPressed: () => router.pop(),
              )
            : null,
        showTabletSidebarToggle: isTablet,
        tabletSidebarExpanded: _tabletSidebarExpanded,
        onTabletSidebarToggle: () {
          setState(() => _tabletSidebarExpanded = !_tabletSidebarExpanded);
        },
        showDesktopSearch: isDesktop,
      ),
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: sidebarWidth,
              child: ClipRect(
                child: AppSidebar(
                  width: sidebarWidth,
                  expanded: sidebarExpanded,
                  selectedPath: path,
                  onDestinationSelected: (target) => context.go(target),
                ),
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
