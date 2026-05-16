import 'package:flutter/material.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.spacingBefore = 0,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final double spacingBefore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(top: spacingBefore),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || subtitle != null || trailing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        if (subtitle case final s?) ...[
                          const SizedBox(height: 6),
                          Text(
                            s,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...switch (trailing) {
                    null => const <Widget>[],
                    final t => <Widget>[t],
                  },
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}
