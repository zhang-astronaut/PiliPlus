import 'package:get/get.dart';

import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

/// Live UI effect toggles (blur / floating bar / liquid glass / predictive back).
/// Values persist to Hive and notify GetX rebuild targets immediately.
class UiStyleController extends GetxController {
  static UiStyleController get to => Get.find();

  final barBlur = Pref.barBlur.obs;
  final floatingNavBar = Pref.floatingNavBar.obs;
  final liquidGlass = Pref.liquidGlass.obs;
  final predictiveBack = Pref.predictiveBack.obs;

  void setBarBlur(bool value) {
    barBlur.value = value;
    GStorage.setting.put(SettingBoxKey.barBlur, value);
  }

  void setFloatingNavBar(bool value) {
    floatingNavBar.value = value;
    GStorage.setting.put(SettingBoxKey.floatingNavBar, value);
  }

  void setLiquidGlass(bool value) {
    liquidGlass.value = value;
    GStorage.setting.put(SettingBoxKey.liquidGlass, value);
  }

  void setPredictiveBack(bool value) {
    predictiveBack.value = value;
    GStorage.setting.put(SettingBoxKey.predictiveBack, value);
  }
}
