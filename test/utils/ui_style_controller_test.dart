import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/ui_style_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('piliplus-uistyle-');
    appSupportDirPath = tempDir.path;
    tmpDirPath = tempDir.path;
    downloadPath = tempDir.path;
    await GStorage.init();
  });

  setUp(() {
    if (Get.isRegistered<UiStyleController>()) {
      Get.delete<UiStyleController>();
    }
    Get.put(UiStyleController());
  });

  tearDownAll(() async {
    await GStorage.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('effect toggle defaults are on', () {
    expect(Pref.barBlur, isTrue);
    expect(Pref.floatingNavBar, isTrue);
    expect(Pref.liquidGlass, isTrue);
    expect(Pref.predictiveBack, isTrue);
  });

  test('effect toggles persist and notify', () {
    final c = UiStyleController.to;

    c
      ..setBarBlur(false)
      ..setFloatingNavBar(false)
      ..setLiquidGlass(false)
      ..setPredictiveBack(false);

    expect(c.barBlur.value, isFalse);
    expect(c.floatingNavBar.value, isFalse);
    expect(c.liquidGlass.value, isFalse);
    expect(c.predictiveBack.value, isFalse);

    expect(GStorage.setting.get(SettingBoxKey.barBlur), isFalse);
    expect(GStorage.setting.get(SettingBoxKey.floatingNavBar), isFalse);
    expect(GStorage.setting.get(SettingBoxKey.liquidGlass), isFalse);
    expect(GStorage.setting.get(SettingBoxKey.predictiveBack), isFalse);

    expect(Pref.barBlur, isFalse);
    expect(Pref.predictiveBack, isFalse);
  });
}
