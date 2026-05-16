import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_button.dart';

/// Premium confirmation dialog inspired by HeroUI Uber theme
/// Clean, minimal, professional appearance
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'حذف',
  String cancelLabel = 'إلغاء',
  AppButtonVariant confirmVariant = AppButtonVariant.danger,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: confirmLabel,
                    variant: confirmVariant,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
