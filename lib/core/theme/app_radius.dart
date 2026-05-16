import 'package:flutter/material.dart';

/// Professional border radius system
/// Inspired by HeroUI & modern SaaS design - no over-rounding
abstract final class AppRadius {
  // —— Base radius values ——
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double full = 9999;

  // —— Border radius objects ——
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // —— Component specific ——
  static final BorderRadius button = radiusMd; // 8px for buttons
  static final BorderRadius input = radiusMd; // 8px for inputs
  static final BorderRadius card = radiusLg; // 12px for cards
  static final BorderRadius dialog = radiusXl; // 16px for dialogs
  static final BorderRadius tooltip = radiusSm; // 6px for tooltips
  static final BorderRadius chip = radiusMd; // 8px for chips
  static final BorderRadius container = radiusLg; // 12px for containers

  // —— Top radius (for bottom sheets, dialogs) ——
  static final BorderRadius topOnlyLarge = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  static final BorderRadius topOnlyXLarge = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
