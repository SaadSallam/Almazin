import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic tokens shared across layouts (cards, page chrome, accents).
@immutable
class AlmazinThemeTokens extends ThemeExtension<AlmazinThemeTokens> {
  const AlmazinThemeTokens({
    required this.canvas,
    required this.card,
    required this.goldAccent,
    required this.brownAccent,
    required this.divider,
    required this.shadow,
    required this.cardShadows,
  });

  final Color canvas;
  final Color card;
  final Color goldAccent;
  final Color brownAccent;
  final Color divider;
  final Color shadow;
  final List<BoxShadow> cardShadows;

  static final AlmazinThemeTokens light = AlmazinThemeTokens(
    canvas: AppColors.lightCanvas,
    card: AppColors.lightSurface,
    goldAccent: AppColors.lightGold,
    brownAccent: AppColors.lightBrown,
    divider: AppColors.lightOutline.withValues(alpha: 0.55),
    shadow: AppColors.lightShadow.withValues(alpha: 0.18),
    cardShadows: [
      BoxShadow(
        color: AppColors.lightShadow.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: AppColors.lightShadow.withValues(alpha: 0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final AlmazinThemeTokens dark = AlmazinThemeTokens(
    canvas: AppColors.darkCanvas,
    card: AppColors.darkSurface,
    goldAccent: AppColors.darkGold,
    brownAccent: AppColors.darkBrown,
    divider: AppColors.darkOutline.withValues(alpha: 0.65),
    shadow: AppColors.darkShadow.withValues(alpha: 0.45),
    cardShadows: [
      BoxShadow(
        color: AppColors.darkShadow.withValues(alpha: 0.55),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: -6,
      ),
    ],
  );

  @override
  AlmazinThemeTokens copyWith({
    Color? canvas,
    Color? card,
    Color? goldAccent,
    Color? brownAccent,
    Color? divider,
    Color? shadow,
    List<BoxShadow>? cardShadows,
  }) {
    return AlmazinThemeTokens(
      canvas: canvas ?? this.canvas,
      card: card ?? this.card,
      goldAccent: goldAccent ?? this.goldAccent,
      brownAccent: brownAccent ?? this.brownAccent,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      cardShadows: cardShadows ?? this.cardShadows,
    );
  }

  @override
  ThemeExtension<AlmazinThemeTokens> lerp(
    ThemeExtension<AlmazinThemeTokens>? other,
    double t,
  ) {
    if (other is! AlmazinThemeTokens) return this;
    return AlmazinThemeTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      card: Color.lerp(card, other.card, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      brownAccent: Color.lerp(brownAccent, other.brownAccent, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
    );
  }
}
