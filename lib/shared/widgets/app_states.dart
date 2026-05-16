import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Premium error state component for all pages
/// Consistent error display with retry action
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: tokens.errorColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: tokens.errorColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium empty state component for all pages
/// Clean, minimal empty state with optional action
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.action,
    this.icon = Icons.inbox_rounded,
  });

  final String message;
  final Widget? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sectionVerticalLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.radiusXl,
              ),
              child: Icon(
                icon,
                size: 48,
                color: tokens.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    height: 1.5,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
