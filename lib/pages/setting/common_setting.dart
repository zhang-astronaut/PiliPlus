import 'package:PiliPlus/common/ui_kit/miuix_page.dart';
import 'package:PiliPlus/models/common/setting_type.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:material_ui/material_ui.dart';

class CommonSetting extends StatefulWidget {
  const CommonSetting({
    super.key,
    required this.settingType,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final SettingType settingType;

  @override
  State<CommonSetting> createState() => _CommonSettingState();
}

class _CommonSettingState extends State<CommonSetting> {
  late List<SettingsModel> settings;

  void _initSetting() {
    settings = widget.settingType.settings;
  }

  @override
  void initState() {
    super.initState();
    _initSetting();
  }

  @override
  void didUpdateWidget(CommonSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settingType != oldWidget.settingType) {
      _initSetting();
    }
  }

  /// Group consecutive preference rows under section titles into MiuixCards.
  List<Widget> _buildGrouped() {
    final result = <Widget>[];
    var buffer = <Widget>[];
    String? sectionTitle;

    void flush() {
      if (buffer.isEmpty) return;
      if (sectionTitle != null) {
        result.add(MiuixSmallTitle(sectionTitle!));
      }
      result.add(
        MiuixCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buffer,
          ),
        ),
      );
      buffer = <Widget>[];
      sectionTitle = null;
    }

    for (final model in settings) {
      if (model is SectionModel) {
        flush();
        sectionTitle = model.sectionTitle;
      } else {
        buffer.add(model.widget);
      }
    }
    flush();
    return result;
  }

  Widget _buildList(EdgeInsets padding) {
    return ListView(
      key: ValueKey(widget.settingType),
      padding: padding,
      children: _buildGrouped(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      // Embedded pane: parent already supplies scaffold padding.
      return _buildList(const EdgeInsets.fromLTRB(12, 0, 12, 100));
    }
    return PiliMiuixPage(
      title: widget.settingType.title,
      content: (context, contentPadding) => _buildList(
        contentPadding.copyWith(
          left: contentPadding.left + 12,
          right: contentPadding.right + 12,
          bottom: contentPadding.bottom + 100,
        ),
      ),
    );
  }
}
