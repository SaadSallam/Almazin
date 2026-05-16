import 'package:flutter/material.dart';

/// Premium grayscale palette closely matching HeroUI Uber theme
/// Neutral elegance, restrained accents, sophisticated layering
/// Enhanced surface separation for clear visual hierarchy
abstract final class AppColors {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT MODE — Clean, minimal, expensive
  // Grayscale-driven with subtle warm undertones
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Surfaces — clear but subtle layering
  static const Color lightCanvas = Color(0xFFF8F8F8); // App background (soft gray)
  static const Color lightSurface = Color(0xFFFFFFFF); // Cards (pure white)
  static const Color lightSurfaceContainer = Color(0xFFF3F3F3); // Elevated containers
  static const Color lightSurfaceHover = Color(0xFFF0F0F0); // Hover state
  static const Color lightSurfaceActive = Color(0xFFEBEBEB); // Active/selected state

  // Text hierarchy — charcoal-driven
  static const Color lightOnSurface = Color(0xFF171717); // Primary (near-black charcoal)
  static const Color lightOnSurfaceMuted = Color(0xFF525252); // Secondary (muted gray)
  static const Color lightOnSurfaceSubtle = Color(0xFFA3A3A3); // Tertiary (soft gray)

  // Accent — restrained, selective use only
  static const Color lightGold = Color(0xFF171717); // Primary = deep charcoal (Uber style)
  static const Color lightOnGold = Color(0xFFFFFFFF); // Text on primary = white
  static const Color lightGoldMuted = Color(0xFF404040); // Hover/disabled
  static const Color lightGoldSubtle = Color(0xFFF5F5F5); // Background tint

  // Secondary accent — warm neutral
  static const Color lightBrown = Color(0xFF737373); // Neutral secondary
  static const Color lightBrownSubtle = Color(0xFFF5F5F5); // Background tint

  // UI elements — thin, low-contrast but visible
  static const Color lightOutline = Color(0xFFE4E4E4); // Borders (soft gray)
  static const Color lightOutlineMuted = Color(0xFFECECEC); // Subtle borders
  static const Color lightDivider = Color(0xFFEAEAEA); // Dividers
  static const Color lightShadow = Color(0xFF171717); // Shadow base

  // Status colors — professional, not vibrant
  static const Color lightError = Color(0xFFDC2626); // Error (professional red)
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightWarning = Color(0xFFD97706); // Warning (muted amber)
  static const Color lightSuccess = Color(0xFF16A34A); // Success (muted green)
  static const Color lightInfo = Color(0xFF2563EB); // Info (muted blue)

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK MODE — Layered charcoal, warm neutrals
  // Matches HeroUI Uber dark aesthetic
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Surfaces — layered dark grays (NO pure black)
  static const Color darkCanvas = Color(0xFF0A0A0A); // App background (deep charcoal)
  static const Color darkSurface = Color(0xFF141414); // Cards (warm dark gray)
  static const Color darkSurfaceContainer = Color(0xFF1C1C1C); // Elevated containers
  static const Color darkSurfaceHover = Color(0xFF242424); // Hover state
  static const Color darkSurfaceActive = Color(0xFF2A2A2A); // Active/selected state

  // Text hierarchy — soft whites
  static const Color darkOnSurface = Color(0xFFFAFAFA); // Primary (soft white)
  static const Color darkOnSurfaceMuted = Color(0xFFA3A3A3); // Secondary (muted gray)
  static const Color darkOnSurfaceSubtle = Color(0xFF737373); // Tertiary (darker gray)

  // Accent — white/light for dark mode (Uber style)
  static const Color darkGold = Color(0xFFFAFAFA); // Primary = soft white
  static const Color darkOnGold = Color(0xFF0A0A0A); // Text on primary = deep charcoal
  static const Color darkGoldMuted = Color(0xFFD4D4D4); // Hover/disabled
  static const Color darkGoldSubtle = Color(0xFF1F1F1F); // Background tint

  // Secondary accent
  static const Color darkBrown = Color(0xFFA3A3A3); // Neutral secondary
  static const Color darkBrownSubtle = Color(0xFF1F1F1F); // Background tint

  // UI elements — muted but visible borders
  static const Color darkOutline = Color(0xFF262626); // Borders (dark gray)
  static const Color darkOutlineMuted = Color(0xFF1F1F1F); // Subtle borders
  static const Color darkDivider = Color(0xFF222222); // Dividers
  static const Color darkShadow = Color(0xFF000000); // Shadow base

  // Status colors — softer for dark mode
  static const Color darkError = Color(0xFFF87171); // Error (soft red)
  static const Color darkOnError = Color(0xFF7F1D1D);
  static const Color darkWarning = Color(0xFFFBBF24); // Warning (soft amber)
  static const Color darkSuccess = Color(0xFF4ADE80); // Success (soft green)
  static const Color darkInfo = Color(0xFF60A5FA); // Info (soft blue)

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NEUTRAL PALETTE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}
