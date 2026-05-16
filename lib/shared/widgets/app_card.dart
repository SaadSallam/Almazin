import 'package:flutter/material.dart';

import '../../core/theme/theme_tokens_x.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.almazinTokens;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: tokens.cardShadows,
        border: Border.all(
          color: tokens.divider.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        hoverColor: scheme.primary.withValues(alpha: 0.06),
        splashColor: scheme.primary.withValues(alpha: 0.10),
        child: card,
      ),
    );
  }
}
