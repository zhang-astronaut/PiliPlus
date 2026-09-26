import 'package:flutter_miuix/miuix.dart';
import 'package:material_ui/material_ui.dart';

class NormalItem extends StatefulWidget {
  final String? title;
  final ValueGetter<String>? getTitle;
  final String? subtitle;
  final ValueGetter<String>? getSubtitle;
  final Widget? leading;
  final Widget Function(ThemeData theme)? getTrailing;
  final void Function(BuildContext context, VoidCallback setState)? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? titleStyle;

  const NormalItem({
    this.title,
    this.getTitle,
    this.subtitle,
    this.getSubtitle,
    this.leading,
    this.getTrailing,
    this.onTap,
    this.contentPadding,
    this.titleStyle,
    super.key,
  }) : assert(title != null || getTitle != null);

  @override
  State<NormalItem> createState() => _NormalItemState();
}

class _NormalItemState extends State<NormalItem> {
  @override
  Widget build(BuildContext context) {
    final trailing = widget.getTrailing?.call(Theme.of(context));
    return MiuixBasicComponent(
      title: widget.title ?? widget.getTitle!(),
      summary: widget.subtitle ?? widget.getSubtitle?.call() ?? '',
      startAction: widget.leading,
      endActions: [
        if (trailing != null) trailing,
        if (widget.onTap != null)
          Icon(
            Icons.chevron_right,
            size: 18,
            color: MiuixTheme.of(context).colors.onSurfaceVariantSummary,
          ),
      ],
      onClick: widget.onTap == null
          ? null
          : () => widget.onTap!(context, refresh),
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
