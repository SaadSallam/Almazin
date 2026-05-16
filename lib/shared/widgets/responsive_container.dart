import 'package:flutter/material.dart';

import '../../core/responsive/responsive_context.dart';
import '../../core/theme/app_spacing.dart';

/// Horizontally padded content with a max width for large screens.
/// Optimized for desktop-first layout with proper spacing
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxWidthDesktop,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  EdgeInsets _padding(BuildContext context) {
    if (context.isMobile) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.contentPaddingMobile,
        vertical: AppSpacing.lg,
      );
    }
    if (context.isTablet) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.contentPaddingTablet,
        vertical: AppSpacing.xl,
      );
    }
    return const EdgeInsets.symmetric(
      horizontal: AppSpacing.contentPaddingDesktop,
      vertical: AppSpacing.xxl,
    );
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
    this.maxWidth = AppSpacing.maxWidthDesktop,
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
