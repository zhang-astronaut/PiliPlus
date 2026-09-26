import 'package:PiliPlus/common/ui_kit/miuix_page.dart';
import 'package:PiliPlus/http/login.dart';
import 'package:PiliPlus/models/common/setting_type.dart';
import 'package:PiliPlus/pages/about/view.dart';
import 'package:PiliPlus/pages/login/controller.dart';
import 'package:PiliPlus/pages/setting/common_setting.dart';
import 'package:PiliPlus/pages/setting/widgets/multi_select_dialog.dart';
import 'package:PiliPlus/pages/webdav/view.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

class _SettingsModel {
  final SettingType type;
  final String? subtitle;
  final IconData icon;

  const _SettingsModel({
    required this.type,
    this.subtitle,
    required this.icon,
  });
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SettingType _type = SettingType.privacySetting;
  final RxBool _noAccount = Accounts.account.isEmpty.obs;
  late bool _isPortrait;

  static const List<_SettingsModel> _items = [
    _SettingsModel(
      type: SettingType.privacySetting,
      subtitle: '黑名单',
      icon: Icons.privacy_tip_outlined,
    ),
    _SettingsModel(
      type: SettingType.recommendSetting,
      subtitle: '推荐来源（web/app）、刷新保留内容、过滤器',
      icon: Icons.explore_outlined,
    ),
    _SettingsModel(
      type: SettingType.videoSetting,
      subtitle: '画质、音质、解码、缓冲、音频输出等',
      icon: Icons.video_settings_outlined,
    ),
    _SettingsModel(
      type: SettingType.playSetting,
      subtitle: '双击/长按、全屏、后台播放、弹幕、字幕、底部进度条等',
      icon: Icons.touch_app_outlined,
    ),
    _SettingsModel(
      type: SettingType.styleSetting,
      subtitle: '横屏适配（平板）、侧栏、列宽、首页、动态红点、主题、字号、图片、帧率等',
      icon: Icons.style_outlined,
    ),
    _SettingsModel(
      type: SettingType.extraSetting,
      subtitle: '震动、搜索、收藏、ai、评论、动态、代理、更新检查等',
      icon: Icons.extension_outlined,
    ),
    _SettingsModel(
      type: SettingType.webdavSetting,
      icon: MdiIcons.databaseCogOutline,
    ),
    _SettingsModel(
      type: SettingType.about,
      icon: Icons.info_outline,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isPortrait = MediaQuery.sizeOf(context).isPortrait;
  }

  @override
  Widget build(BuildContext context) {
    return PiliMiuixPage(
      title: _isPortrait ? '设置' : _type.title,
      content: (context, padding) => _isPortrait
          ? Padding(padding: padding, child: _buildList(context))
          : Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _buildList(context)),
                  VerticalDivider(
                    width: 1,
                    color: MiuixTheme.of(
                      context,
                    ).colors.dividerLine.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    flex: 6,
                    child: switch (_type) {
                      .privacySetting ||
                      .recommendSetting ||
                      .videoSetting ||
                      .playSetting ||
                      .styleSetting ||
                      .extraSetting => CommonSetting(
                        settingType: _type,
                        showAppBar: false,
                      ),
                      .webdavSetting => const WebDavSettingPage(
                        showAppBar: false,
                      ),
                      .about => const AboutPage(showAppBar: false),
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _noAccount.close();
    super.dispose();
  }

  void _toPage(SettingType type) {
    if (_isPortrait) {
      Get.to(
        () => switch (type) {
          .privacySetting ||
          .recommendSetting ||
          .videoSetting ||
          .playSetting ||
          .styleSetting ||
          .extraSetting => CommonSetting(settingType: type),
          .webdavSetting => const WebDavSettingPage(),
          .about => const AboutPage(),
        },
      );
    } else {
      _type = type;
      setState(() {});
    }
  }

  MiuixBasicComponentColors? _titleColor(SettingType type) {
    if (_isPortrait || type != _type) return null;
    final colors = MiuixTheme.of(context).colors;
    return MiuixBasicComponentColors(
      color: colors.primary,
      disabledColor: colors.disabledOnSecondaryVariant,
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100, left: 12, right: 12),
      children: [
        _buildSearchItem(context),
        MiuixCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._items.take(_items.length - 1).map(
                (item) => MiuixArrowPreference(
                  title: item.type.title,
                  summary: item.subtitle,
                  titleColor: _titleColor(item.type),
                  startAction: MiuixIcon(icon: item.icon, size: 22),
                  onClick: () => _toPage(item.type),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MiuixCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixArrowPreference(
                title: '切换账号',
                startAction: const MiuixIcon(
                  icon: Icons.switch_account_outlined,
                  size: 22,
                ),
                onClick: () => LoginPageController.switchAccountDialog(context),
              ),
              Obx(
                () => _noAccount.value
                    ? const SizedBox.shrink()
                    : MiuixArrowPreference(
                        title: '退出登录',
                        startAction: const MiuixIcon(
                          icon: Icons.logout_outlined,
                          size: 22,
                        ),
                        onClick: () => _logoutDialog(context),
                      ),
              ),
              MiuixArrowPreference(
                title: _items.last.type.title,
                titleColor: _titleColor(_items.last.type),
                startAction: MiuixIcon(icon: _items.last.icon, size: 22),
                onClick: () => _toPage(_items.last.type),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _removeAccounts(Set<LoginAccount> accounts) async {
    await Accounts.deleteAll(accounts);
    if (mounted) _noAccount.value = Accounts.account.isEmpty;
  }

  static Future<LoginAccount?> _logoutWrapper(LoginAccount account) async {
    try {
      final res = await LoginHttp.logout(account);
      return res.isSuccess ? account : null;
    } catch (e, s) {
      Utils.reportError(e, s);
      return null;
    }
  }

  Future<void> _logoutDialog(BuildContext context) async {
    final result = await showDialog<Set<LoginAccount>>(
      context: context,
      builder: (context) => MultiSelectDialog<LoginAccount>(
        title: '选择要登出的账号uid',
        initValues: const Iterable.empty(),
        values: {
          for (final i in Accounts.account.values) i: i.mid.toString(),
        },
      ),
    );
    if (!context.mounted || result == null || result.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        final colors = MiuixTheme.of(context).colors;
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
            "确认要退出以下账号登录吗\n\n${result.map((i) => i.mid).join('\n')}",
          ),
          actions: [
            MiuixTextButton(
              '点错了',
              onPressed: Get.back,
              textStyle: TextStyle(color: colors.onSurfaceVariantSummary),
            ),
            MiuixTextButton(
              '仅登出',
              onPressed: () {
                Get.back();
                _removeAccounts(result);
              },
              textStyle: TextStyle(color: colors.error),
            ),
            MiuixButton(
              onPressed: () async {
                SmartDialog.showLoading();
                final res = await Future.wait(result.map(_logoutWrapper));
                SmartDialog.dismiss();
                final logoutAccounts = res.nonNulls.toSet();
                if (logoutAccounts.isEmpty) {
                  SmartDialog.showToast('所选账号均退出登录失败');
                } else {
                  Get.back();
                  _removeAccounts(logoutAccounts);
                  if (logoutAccounts.length != result.length) {
                    result.removeWhere(logoutAccounts.contains);
                    SmartDialog.showToast(
                      '账号 ${result.map((i) => i.mid).join(",")} 退出登录失败',
                    );
                  }
                }
              },
              child: const MiuixText('确认'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchItem(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: MiuixCard(
      onPressed: () => Get.toNamed('/settingsSearch'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiuixIcon(vector: MiuixIcons.basic.search, size: 18),
            const SizedBox(width: 6),
            const MiuixText('搜索'),
          ],
        ),
      ),
    ),
  );
}
