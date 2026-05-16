import 'package:flutter/material.dart';

import '../../core/responsive/responsive_context.dart';

/// Horizontally padded content with a max width for large screens.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1240,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  EdgeInsets _padding(BuildContext context) {
    if (context.isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
    if (context.isTablet) {
      return const EdgeInsets.symmetric(horizontal: 22, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 28, vertical: 24);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: _padding(context),
          child: child,
        ),
      ),
    );
  }
}

/// Max width helper for full-width sections inside the shell body.
class ResponsiveMaxWidth extends StatelessWidget {
  const ResponsiveMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1240,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
