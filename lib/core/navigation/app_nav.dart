import 'package:flutter/material.dart';

import 'app_paths.dart';

@immutable
class AppNavItem {
  const AppNavItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;

  static const List<AppNavItem> main = [
    AppNavItem(
      path: AppPaths.coffeePrices,
      label: 'أسعار البن',
      icon: Icons.local_cafe_outlined,
    ),
    AppNavItem(
      path: AppPaths.customers,
      label: 'العملاء',
      icon: Icons.people_alt_outlined,
    ),
    AppNavItem(
      path: AppPaths.calculator,
      label: 'حاسبة التوليفة',
      icon: Icons.calculate_outlined,
    ),
    AppNavItem(
      path: AppPaths.settings,
      label: 'الإعدادات',
      icon: Icons.settings_outlined,
    ),
  ];
}

bool isNavPathActive(String currentLocation, String navPath) {
  final path = Uri.parse(currentLocation).path;
  return path == navPath || path.startsWith('$navPath/');
}

String appPageTitleForLocation(String location) {
  final path = Uri.parse(location).path;
  if (path.startsWith('${AppPaths.customers}/') && path != AppPaths.customers) {
    return 'تفاصيل العميل';
  }
  for (final item in AppNavItem.main) {
    if (path == item.path) {
      return item.label;
    }
  }
  return 'المازن';
}
