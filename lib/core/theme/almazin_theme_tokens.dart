import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';

/// Premium semantic tokens matching HeroUI Uber theme
/// Grayscale-driven, neutral elegance, restrained accents
@immutable
class AlmazinThemeTokens extends ThemeExtension<AlmazinThemeTokens> {
  const AlmazinThemeTokens({
    required this.canvas,
    required this.surfaceDefault,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.surfaceContainer,
    required this.primary,
    required this.onPrimary,
    required this.primaryMuted,
    required this.primarySubtle,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.shadow,
    required this.cardShadows,
    required this.hoverShadows,
    required this.mediumShadows,
    required this.highShadows,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SURFACE HIERARCHY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color canvas; // App background
  final Color surfaceDefault; // Cards, containers
  final Color surfaceHover; // Hover state
  final Color surfaceActive; // Active/selected state
  final Color surfaceContainer; // Elevated containers

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIMARY ACCENT (charcoal in light, white in dark)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color primary; // Primary interactive color
  final Color onPrimary; // Text on primary
  final Color primaryMuted; // Primary hover/disabled
  final Color primarySubtle; // Primary background tint

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECONDARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color secondary; // Secondary accent

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT HIERARCHY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color textPrimary; // Main text
  final Color textSecondary; // Secondary text
  final Color textTertiary; // Muted text

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UI ELEMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color divider;
  final Color shadow;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SHADOW SYSTEM
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final List<BoxShadow> cardShadows;
  final List<BoxShadow> hoverShadows;
  final List<BoxShadow> mediumShadows;
  final List<BoxShadow> highShadows;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  static final AlmazinThemeTokens light = AlmazinThemeTokens(
    // Surfaces — clear but subtle layering
    canvas: AppColors.lightCanvas,
    surfaceDefault: AppColors.lightSurface,
    surfaceHover: AppColors.lightSurfaceHover,
    surfaceActive: AppColors.lightSurfaceActive,
    surfaceContainer: AppColors.lightSurfaceContainer,

    // Primary — deep charcoal (Uber style)
    primary: AppColors.lightGold,
    onPrimary: AppColors.lightOnGold,
    primaryMuted: AppColors.lightGoldMuted,
    primarySubtle: AppColors.lightGoldSubtle,

    // Secondary
    secondary: AppColors.lightBrown,

    // Text hierarchy — charcoal-driven
    textPrimary: AppColors.lightOnSurface,
    textSecondary: AppColors.lightOnSurfaceMuted,
    textTertiary: AppColors.lightOnSurfaceSubtle,

    // UI elements — thin, low-contrast
    divider: AppColors.lightOutline.withValues(alpha: 0.6),
    shadow: AppColors.lightShadow.withValues(alpha: 0.08),

    // Shadows
    cardShadows: AppShadows.lightCard,
    hoverShadows: AppShadows.lightHover,
    mediumShadows: AppShadows.lightMedium,
    highShadows: AppShadows.lightHigh,

    // Status
    successColor: AppColors.lightSuccess,
    warningColor: AppColors.lightWarning,
    errorColor: AppColors.lightError,
  );

  static final AlmazinThemeTokens dark = AlmazinThemeTokens(
    // Surfaces — layered dark grays
    canvas: AppColors.darkCanvas,
    surfaceDefault: AppColors.darkSurface,
    surfaceHover: AppColors.darkSurfaceHover,
    surfaceActive: AppColors.darkSurfaceActive,
    surfaceContainer: AppColors.darkSurfaceContainer,

    // Primary — soft white (Uber dark style)
    primary: AppColors.darkGold,
    onPrimary: AppColors.darkOnGold,
    primaryMuted: AppColors.darkGoldMuted,
    primarySubtle: AppColors.darkGoldSubtle,

    // Secondary
    secondary: AppColors.darkBrown,

    // Text hierarchy — soft whites
    textPrimary: AppColors.darkOnSurface,
    textSecondary: AppColors.darkOnSurfaceMuted,
    textTertiary: AppColors.darkOnSurfaceSubtle,

    // UI elements — muted borders
    divider: AppColors.darkOutline.withValues(alpha: 0.7),
    shadow: AppColors.darkShadow.withValues(alpha: 0.25),

    // Shadows
    cardShadows: AppShadows.darkCard,
    hoverShadows: AppShadows.darkHover,
    mediumShadows: AppShadows.darkMedium,
    highShadows: AppShadows.darkHigh,

    // Status
    successColor: AppColors.darkSuccess,
    warningColor: AppColors.darkWarning,
    errorColor: AppColors.darkError,
  );

  @override
  AlmazinThemeTokens copyWith({
    Color? canvas,
    Color? surfaceDefault,
    Color? surfaceHover,
    Color? surfaceActive,
    Color? surfaceContainer,
    Color? primary,
    Color? onPrimary,
    Color? primaryMuted,
    Color? primarySubtle,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? shadow,
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? hoverShadows,
    List<BoxShadow>? mediumShadows,
    List<BoxShadow>? highShadows,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return AlmazinThemeTokens(
      canvas: canvas ?? this.canvas,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      cardShadows: cardShadows ?? this.cardShadows,
      hoverShadows: hoverShadows ?? this.hoverShadows,
      mediumShadows: mediumShadows ?? this.mediumShadows,
      highShadows: highShadows ?? this.highShadows,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
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
      surfaceDefault: Color.lerp(surfaceDefault, other.surfaceDefault, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceActive: Color.lerp(surfaceActive, other.surfaceActive, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      hoverShadows: t < 0.5 ? hoverShadows : other.hoverShadows,
      mediumShadows: t < 0.5 ? mediumShadows : other.mediumShadows,
      highShadows: t < 0.5 ? highShadows : other.highShadows,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}
