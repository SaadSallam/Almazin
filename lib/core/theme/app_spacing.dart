/// Professional spacing system (8px base unit)
/// Aligns with HeroUI and modern SaaS design
abstract final class AppSpacing {
  // —— Base units ——
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double vast = 64;

  // —— Common combinations ——
  static const double contentPaddingMobile = 16;
  static const double contentPaddingTablet = 22;
  static const double contentPaddingDesktop = 28;

  // —— Component spacing ——
  static const double buttonHeight = 40;
  static const double buttonHeightSmall = 32;
  static const double buttonHeightLarge = 48;

  static const double inputHeight = 40;
  static const double inputHeightCompact = 36;

  static const double sidebarWidthCollapsed = 84;
  static const double sidebarWidthExpanded = 270;

  // —— Gap spacing ——
  static const double gapSmall = 8;
  static const double gapMedium = 12;
  static const double gapRegular = 16;
  static const double gapLarge = 20;
  static const double gapXLarge = 24;

  // —— Section spacing ——
  static const double sectionVerticalSmall = 16;
  static const double sectionVerticalMedium = 20;
  static const double sectionVerticalLarge = 28;

  // —— Responsive max-width ——
  static const double maxWidthDesktop = 1400;
  static const double maxWidthContent = 1200;
}
