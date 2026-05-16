import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:almazin_app/app/almazin_app.dart';
import 'package:almazin_app/core/storage/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('almazin_hive');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>(kAlmazinSettingsBox);
    await Hive.openBox<dynamic>(kAlmazinDataBox);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(kAlmazinSettingsBox);
    await Hive.deleteBoxFromDisk(kAlmazinDataBox);
    await Hive.close();
  });

  testWidgets('AlmazinApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const AlmazinApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('المازن'), findsWidgets);
  });
}
