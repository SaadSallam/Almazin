import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Premium section component with improved visual grouping
/// Clear section boundaries, subtle background, refined typography
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.spacingBefore = 0,
    this.grouped = false, // Adds subtle background + border for section grouping
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final double spacingBefore;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    final header = (title != null || subtitle != null || trailing != null)
        ? Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title case final t?)
                        Text(
                          t,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                      if (subtitle case final s?) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          s,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  trailing!,
                ],
              ],
            ),
          )
        : null;

    if (grouped && header != null) {
      return Padding(
        padding: EdgeInsets.only(top: spacingBefore),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: tokens.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: AppRadius.card,
            border: Border.all(color: tokens.divider.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              child,
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: spacingBefore),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...[if (header != null) header],
          child,
        ],
      ),
    );
  }
}
