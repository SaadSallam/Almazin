import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }
enum AppButtonSize { small, medium, large }

/// Premium button component matching HeroUI Uber theme
/// Charcoal primary (light), white primary (dark), subtle secondary
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;

    final (bgColor, fgColor, borderColor) = _resolveColors(scheme, tokens);
    final height = _resolveHeight();
    final fontSize = _resolveFontSize();
    final horizontalPadding = _resolvePadding();

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      height: height,
      constraints: widget.fullWidth ? const BoxConstraints(minWidth: double.infinity) : null,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.button,
        border: widget.variant == AppButtonVariant.secondary
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: _isHovered && widget.variant == AppButtonVariant.primary
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: fontSize * 1.2,
              height: fontSize * 1.2,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
          ] else if (widget.icon != null) ...[
            Icon(widget.icon, size: fontSize * 1.1, color: fgColor),
            SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          scale: _isPressed ? 0.98 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.button,
              onTap: widget.isLoading ? null : widget.onPressed,
              hoverColor: Colors.transparent,
              splashColor: scheme.primary.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  (Color bg, Color fg, Color border) _resolveColors(ColorScheme scheme, AlmazinThemeTokens tokens) {
    final isDisabled = widget.onPressed == null;

    return switch (widget.variant) {
      // Primary: charcoal (light) or white (dark)
      AppButtonVariant.primary => (
          isDisabled ? scheme.primary.withValues(alpha: 0.4) : (_isHovered ? tokens.primaryMuted : scheme.primary),
          isDisabled ? scheme.onPrimary.withValues(alpha: 0.6) : scheme.onPrimary,
          Colors.transparent,
        ),
      // Secondary: transparent bg, outline border
      AppButtonVariant.secondary => (
          isDisabled ? Colors.transparent : (_isHovered ? scheme.surfaceContainerHighest.withValues(alpha: 0.4) : Colors.transparent),
          isDisabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface,
          isDisabled ? scheme.outline.withValues(alpha: 0.2) : scheme.outline.withValues(alpha: 0.5),
        ),
      // Ghost: transparent, text only
      AppButtonVariant.ghost => (
          isDisabled ? Colors.transparent : (_isHovered ? scheme.surfaceContainerHighest.withValues(alpha: 0.4) : Colors.transparent),
          isDisabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface,
          Colors.transparent,
        ),
      // Danger: error color
      AppButtonVariant.danger => (
          isDisabled ? scheme.error.withValues(alpha: 0.4) : scheme.error,
          isDisabled ? scheme.onError.withValues(alpha: 0.6) : scheme.onError,
          isDisabled ? scheme.error.withValues(alpha: 0.2) : scheme.error.withValues(alpha: 0.4),
        ),
    };
  }

  double _resolveHeight() {
    return switch (widget.size) {
      AppButtonSize.small => AppSpacing.buttonHeightSmall,
      AppButtonSize.medium => AppSpacing.buttonHeight,
      AppButtonSize.large => AppSpacing.buttonHeightLarge,
    };
  }

  double _resolveFontSize() {
    return switch (widget.size) {
      AppButtonSize.small => 12,
      AppButtonSize.medium => 14,
      AppButtonSize.large => 15,
    };
  }

  double _resolvePadding() {
    return switch (widget.size) {
      AppButtonSize.small => AppSpacing.md,
      AppButtonSize.medium => AppSpacing.xl,
      AppButtonSize.large => AppSpacing.xxl,
    };
  }
}
