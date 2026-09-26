import 'dart:math';

import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SelectItem, Setting, SettingSwitch;
import 'package:flutter_miuix/miuix.dart';
import 'package:material_ui/material_ui.dart';

class ImSettingsItem extends StatelessWidget {
  const ImSettingsItem({
    super.key,
    required this.item,
    required this.onSet,
    required this.onRedirect,
  });

  final Setting item;
  final Future<bool> Function() onSet;
  final VoidCallback onRedirect;

  @override
  Widget build(BuildContext context) {
    void rebuild() {
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    }

    final colorScheme = ColorScheme.of(context);
    final outline = colorScheme.outline;

    if (item.hasSwitch_1()) {
      Future<void> onChanged() async {
        item.switch_1.switchOn = !item.switch_1.switchOn;
        rebuild();
        if (!await onSet()) {
          item.switch_1.switchOn = !item.switch_1.switchOn;
          rebuild();
        }
      }

      return MiuixSwitchPreference(
        title: item.switch_1.title,
        summary: item.switch_1.hasSubtitle() ? item.switch_1.subtitle : '',
        value: item.switch_1.switchOn,
        onChanged: (_) => onChanged(),
      );
    }

    if (item.hasRedirect()) {
      SelectItem? selected;
      SettingSwitch? sw1tch;
      if (item.redirect.settingPage.subSettings.isNotEmpty) {
        for (final subItem in item.redirect.settingPage.subSettings.values) {
          if (subItem.hasSelect()) {
            for (final i in subItem.select.item) {
              if (i.selected) {
                selected = i;
                break;
              }
            }
          } else if (subItem.hasSwitch_1()) {
            if (subItem.switch_1.switchOn) {
              sw1tch = subItem.switch_1;
              break;
            }
          }
        }
      }
      final summaryText = selected?.text ??
          sw1tch?.title ??
          (item.redirect.hasSelectedSummary()
              ? item.redirect.selectedSummary
              : '');
      return MiuixArrowPreference(
        title: item.redirect.title,
        summary: item.redirect.hasSubtitle()
            ? item.redirect.subtitle
            : summaryText,
        endActions: [
          if (summaryText.isNotEmpty)
            Text(
              summaryText,
              style: TextStyle(fontSize: 13, color: outline),
            ),
        ],
        onClick: onRedirect,
      );
    }

    if (item.hasSelect()) {
      String? selected;
      late final divider = Divider(
        height: 1,
        indent: 16,
        color: outline.withValues(alpha: 0.1),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          max(0, item.select.item.length * 2 - 1),
          (index) {
            if (index.isOdd) {
              return divider;
            }
            final e = item.select.item[index ~/ 2];
            if (e.selected) {
              selected ??= e.text;
            }
            return MiuixBasicComponent(
              title: e.text,
              endActions: [
                if (e.selected)
                  MiuixIcon(
                    icon: Icons.check,
                    size: 20,
                    tint: colorScheme.primary,
                  ),
              ],
              onClick: () async {
                if (!e.selected) {
                  for (final i in item.select.item) {
                    i.selected = false;
                  }
                  e.selected = true;
                  rebuild();

                  if (await onSet()) {
                    selected = e.text;
                  } else {
                    for (final i in item.select.item) {
                      i.selected = i.text == selected;
                    }
                    rebuild();
                  }
                }
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
