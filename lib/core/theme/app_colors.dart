import 'package:flutter/material.dart';

/// Central color primitives for the coffee-inspired palette.
/// Widgets must use [Theme.of] / [ColorScheme] / [AlmazinThemeTokens], not these directly.
abstract final class AppColors {
  // —— Light ——
  static const Color lightCanvas = Color(0xFFF5EFE6);
  static const Color lightSurface = Color(0xFFFAF6EF);
  static const Color lightSurfaceContainer = Color(0xFFEDE4D6);
  static const Color lightOnSurface = Color(0xFF2A2520);
  static const Color lightOnSurfaceMuted = Color(0xFF5C534A);
  static const Color lightGold = Color(0xFFB8922A);
  static const Color lightOnGold = Color(0xFF1C1408);
  static const Color lightGoldMuted = Color(0xFFD4B87A);
  static const Color lightBrown = Color(0xFF6B5344);
  static const Color lightOutline = Color(0xFFCBBFAF);
  static const Color lightShadow = Color(0xFF3A2F26);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // —— Dark ——
  static const Color darkCanvas = Color(0xFF0E0C0A);
  static const Color darkSurface = Color(0xFF161311);
  static const Color darkSurfaceContainer = Color(0xFF1F1B18);
  static const Color darkOnSurface = Color(0xFFF3EBE0);
  static const Color darkOnSurfaceMuted = Color(0xFFC9B8A6);
  static const Color darkGold = Color(0xFFD4AF37);
  static const Color darkOnGold = Color(0xFF1A1408);
  static const Color darkGoldMuted = Color(0xFF9A7E2E);
  static const Color darkBrown = Color(0xFF8B6239);
  static const Color darkOutline = Color(0xFF4A4238);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
}
