import 'package:flutter/material.dart';

import 'responsive_container.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.child,
    this.bottomSpacing = 32,
  });

  final Widget child;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasInfiniteHeight ? 0.0 : constraints.maxHeight;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpacing),
              child: ResponsiveContainer(child: child),
            ),
          ),
        );
      },
    );
  }
}
