import 'package:hive_flutter/hive_flutter.dart';

/// Hive box name for app settings (theme, etc.).
const String kAlmazinSettingsBox = 'almazin_settings';

/// Hive box name for persisted domain data (coffee prices, etc.).
const String kAlmazinDataBox = 'almazin_data';

Future<void> initAppStorage() async {
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(kAlmazinSettingsBox);
  await Hive.openBox<dynamic>(kAlmazinDataBox);
}
