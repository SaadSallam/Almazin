import 'package:flutter/material.dart';

import 'app/almazin_app.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();
  await initAppStorage();
  runApp(const AlmazinApp());
}
