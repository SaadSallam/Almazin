import 'package:flutter/material.dart';

import 'almazin_theme_tokens.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// Builds [ThemeData] for light and dark appearance using [AppColors] + [AlmazinThemeTokens].
abstract final class AppTheme {
  static ThemeData light() {
    final tokens = AlmazinThemeTokens.light;
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: tokens.goldAccent,
      onPrimary: AppColors.lightOnGold,
      primaryContainer: AppColors.lightGoldMuted.withValues(alpha: 0.35),
      onPrimaryContainer: AppColors.lightOnSurface,
      secondary: tokens.brownAccent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSurfaceContainer,
      onSecondaryContainer: AppColors.lightOnSurface,
      surface: tokens.card,
      onSurface: AppColors.lightOnSurface,
      surfaceContainerHighest: AppColors.lightSurfaceContainer,
      onSurfaceVariant: AppColors.lightOnSurfaceMuted,
      outline: AppColors.lightOutline,
      shadow: tokens.shadow,
      scrim: AppColors.lightShadow.withValues(alpha: 0.35),
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
    );

    return _build(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      tokens: tokens,
    );
  }

  static ThemeData dark() {
    final tokens = AlmazinThemeTokens.dark;
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: tokens.goldAccent,
      onPrimary: AppColors.darkOnGold,
      primaryContainer: AppColors.darkGoldMuted.withValues(alpha: 0.35),
      onPrimaryContainer: AppColors.darkOnSurface,
      secondary: tokens.brownAccent,
      onSecondary: AppColors.darkOnSurface,
      secondaryContainer: AppColors.darkSurfaceContainer,
      onSecondaryContainer: AppColors.darkOnSurface,
      surface: tokens.card,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceContainer,
      onSurfaceVariant: AppColors.darkOnSurfaceMuted,
      outline: AppColors.darkOutline,
      shadow: tokens.shadow,
      scrim: AppColors.darkShadow.withValues(alpha: 0.55),
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
    );

    return _build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      tokens: tokens,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required AlmazinThemeTokens tokens,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: tokens.canvas,
      extensions: <ThemeExtension<dynamic>>[tokens],
      dividerTheme: DividerThemeData(color: tokens.divider, thickness: 1),
      shadowColor: tokens.shadow,
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.family,
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: AppFonts.family,
        bodyColor: colorScheme.onPrimary,
        displayColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        labelStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((_) {
          return TextStyle(fontFamily: AppFonts.family);
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.canvas,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: AppFonts.family,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: brightness == Brightness.light ? 0 : 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: brightness == Brightness.light ? 1 : 0,
          shadowColor: tokens.shadow,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: TextStyle(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.55)),
          textStyle: TextStyle(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          fontFamily: AppFonts.family,
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
