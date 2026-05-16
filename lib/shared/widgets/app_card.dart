import 'package:flutter/material.dart';

import '../../core/theme/almazin_theme_tokens.dart';
import '../../core/theme/app_radius.dart';

/// Premium card component matching HeroUI Uber theme
/// Clear surface separation, subtle hover, refined borders
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.elevated = false,
    this.hoverable = true,
    this.active = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated; // Adds subtle shadow elevation
  final bool hoverable; // Enables hover state changes
  final bool active; // Active/selected state

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;

    final isActive = widget.active;
    final isHovered = _isHovered && widget.hoverable;

    final bgColor = isActive
        ? tokens.surfaceActive
        : isHovered
            ? tokens.surfaceHover
            : tokens.surfaceDefault;

    final borderColor = isActive
        ? scheme.primary.withValues(alpha: 0.2)
        : isHovered
            ? scheme.primary.withValues(alpha: 0.12)
            : tokens.divider.withValues(alpha: 0.5);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
        boxShadow: widget.elevated
            ? (isHovered ? tokens.mediumShadows : tokens.cardShadows)
            : null,
        border: Border.all(
          color: borderColor,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.onTap == null) {
      return card;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: widget.onTap,
          hoverColor: Colors.transparent,
          splashColor: scheme.primary.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          child: card,
        ),
      ),
    );
  }
}
