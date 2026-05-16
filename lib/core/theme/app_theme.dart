import 'package:flutter/material.dart';

import 'almazin_theme_tokens.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Premium [ThemeData] matching HeroUI Uber theme
/// Grayscale-driven, neutral elegance, desktop-first
abstract final class AppTheme {
  static ThemeData light() {
    final tokens = AlmazinThemeTokens.light;
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: tokens.primary, // Deep charcoal
      onPrimary: tokens.onPrimary, // White
      primaryContainer: tokens.primarySubtle,
      onPrimaryContainer: tokens.textPrimary,
      secondary: tokens.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.lightBrownSubtle,
      onSecondaryContainer: tokens.textPrimary,
      surface: tokens.surfaceDefault,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.surfaceContainer,
      onSurfaceVariant: tokens.textSecondary,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineMuted,
      shadow: tokens.shadow,
      scrim: AppColors.lightShadow.withValues(alpha: 0.2),
      error: tokens.errorColor,
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
      primary: tokens.primary, // Soft white
      onPrimary: tokens.onPrimary, // Deep charcoal
      primaryContainer: tokens.primarySubtle,
      onPrimaryContainer: tokens.textPrimary,
      secondary: tokens.secondary,
      onSecondary: tokens.textPrimary,
      secondaryContainer: AppColors.darkBrownSubtle,
      onSecondaryContainer: tokens.textPrimary,
      surface: tokens.surfaceDefault,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.surfaceContainer,
      onSurfaceVariant: tokens.textSecondary,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineMuted,
      shadow: tokens.shadow,
      scrim: AppColors.darkShadow.withValues(alpha: 0.4),
      error: tokens.errorColor,
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
      dividerTheme: DividerThemeData(
        color: tokens.divider,
        thickness: 1,
        space: 0,
      ),
      shadowColor: tokens.shadow,
    );

    return base.copyWith(
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // TYPOGRAPHY
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // INPUT FIELDS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.lightSurfaceContainer.withValues(alpha: 0.5)
            : AppColors.darkSurfaceContainer.withValues(alpha: 0.5),
        labelStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((_) {
          return TextStyle(
            fontFamily: AppFonts.family,
            color: colorScheme.primary,
            fontSize: 12,
          );
        }),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // APP BAR
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // CARDS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      cardTheme: CardThemeData(
        color: tokens.surfaceDefault,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        margin: EdgeInsets.zero,
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // BUTTONS — Uber style: charcoal primary, neutral secondary
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: TextStyle(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
          textStyle: TextStyle(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          textStyle: TextStyle(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // DIALOGS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceDefault,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        elevation: 0,
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // SNACK BARS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          fontFamily: AppFonts.family,
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // TOOLTIPS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: brightness == Brightness.light
              ? AppColors.lightOnSurface.withValues(alpha: 0.9)
              : AppColors.darkOnSurface.withValues(alpha: 0.9),
          borderRadius: AppRadius.tooltip,
        ),
        textStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: brightness == Brightness.light
              ? AppColors.lightSurface
              : AppColors.darkCanvas,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // CHIPS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
    );
  }
}
