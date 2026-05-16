import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => AppBreakpoints.isMobile(screenWidth);

  bool get isTablet => AppBreakpoints.isTablet(screenWidth);

  bool get isDesktop => AppBreakpoints.isDesktop(screenWidth);
}
