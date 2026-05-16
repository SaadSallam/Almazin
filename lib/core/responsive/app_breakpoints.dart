/// Layout breakpoints for the Almazin shell (width in logical pixels).
abstract final class AppBreakpoints {
  static const double mobileMax = 719;
  static const double tabletMax = 1199;

  static bool isMobile(double width) => width <= mobileMax;

  static bool isTablet(double width) =>
      width > mobileMax && width <= tabletMax;

  static bool isDesktop(double width) => width > tabletMax;
}
