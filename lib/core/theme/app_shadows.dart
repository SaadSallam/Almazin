import 'package:flutter/material.dart';

/// Professional shadow system for subtle, premium elevation
/// Inspired by HeroUI & modern SaaS (soft, not harsh)
abstract final class AppShadows {
  // —— Light mode shadows ——
  static List<BoxShadow> lightNone = [];

  /// Subtle hover lift - used for interactive elements
  static List<BoxShadow> lightHover = [
    BoxShadow(
      color: const Color(0xFF3A2F26).withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Light card elevation - used for cards, containers
  static List<BoxShadow> lightCard = [
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.03),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  /// Medium elevation - used for dropdowns, menus
  static List<BoxShadow> lightMedium = [
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.10),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// High elevation - used for modals, dialogs
  static List<BoxShadow> lightHigh = [
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.14),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // —— Dark mode shadows ——
  static List<BoxShadow> darkNone = [];

  /// Subtle hover lift - dark mode
  static List<BoxShadow> darkHover = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.20),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Light card elevation - dark mode
  static List<BoxShadow> darkCard = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.25),
      blurRadius: 6,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.12),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  /// Medium elevation - dark mode
  static List<BoxShadow> darkMedium = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.35),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.15),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// High elevation - dark mode
  static List<BoxShadow> darkHigh = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.45),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.20),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // —— Utility methods ——
  static List<BoxShadow> getCardShadows(Brightness brightness) {
    return brightness == Brightness.light ? lightCard : darkCard;
  }

  static List<BoxShadow> getHoverShadows(Brightness brightness) {
    return brightness == Brightness.light ? lightHover : darkHover;
  }

  static List<BoxShadow> getMediumShadows(Brightness brightness) {
    return brightness == Brightness.light ? lightMedium : darkMedium;
  }

  static List<BoxShadow> getHighShadows(Brightness brightness) {
    return brightness == Brightness.light ? lightHigh : darkHigh;
  }
}
