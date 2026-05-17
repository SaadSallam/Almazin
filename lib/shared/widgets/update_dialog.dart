import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/update/update_model.dart';
import '../../core/update/version_utils.dart';
import '../widgets/app_button.dart';

/// Modern update dialog matching HeroUI/Uber aesthetic.
/// Clean, minimal, desktop-first design.
class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestRelease,
    required this.onUpdate,
    required this.onRemindLater,
    required this.onSkipVersion,
  });

  final String currentVersion;
  final ReleaseInfo latestRelease;
  final VoidCallback onUpdate;
  final VoidCallback onRemindLater;
  final VoidCallback onSkipVersion;

  @override
  UpdateDialogState createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  bool _isUpdating = false;
  double _downloadProgress = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(
                      Icons.system_update_outlined,
                      color: scheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحديث متاح',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'إصدار جديد جاهز للتثبيت',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Version info
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: tokens.surfaceContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.divider.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإصدار الحالي',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: tokens.textTertiary,
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            VersionUtils.display(widget.currentVersion),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_back, size: 16, color: tokens.textTertiary),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإصدار الجديد',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: tokens.textTertiary,
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            VersionUtils.display(widget.latestRelease.tagName),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Release notes
              if (widget.latestRelease.body.isNotEmpty) ...[
                Text(
                  'ملاحظات الإصدار',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainer.withValues(alpha: 0.3),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.latestRelease.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textSecondary,
                            height: 1.5,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Progress bar (when downloading)
              if (_isUpdating) ...[
                LinearProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  minHeight: 4,
                  borderRadius: AppRadius.radiusXs,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _downloadProgress > 0
                      ? 'جاري التحميل... ${(_downloadProgress * 100).toInt()}%'
                      : 'جاري التحميل...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    label: 'تخطي هذا الإصدار',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.small,
                    onPressed: _isUpdating ? null : widget.onSkipVersion,
                  ),
                  Row(
                    children: [
                      AppButton(
                        label: 'لاحقاً',
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                        onPressed: _isUpdating ? null : widget.onRemindLater,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton(
                        label: _isUpdating ? 'جاري التحديث...' : 'تحديث الآن',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.small,
                        isLoading: _isUpdating,
                        onPressed: _isUpdating ? null : _handleUpdate,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpdate() {
    setState(() => _isUpdating = true);
    widget.onUpdate();
  }

  /// Update download progress from outside.
  void updateProgress(double progress) {
    if (mounted) {
      setState(() => _downloadProgress = progress);
    }
  }
}
