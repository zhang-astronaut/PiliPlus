import 'dart:ui';

import 'package:flutter_miuix/miuix.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import 'package:PiliPlus/utils/ui_style_controller.dart';

/// Material-style back affordance rendered with [MiuixIcon].
class PiliBackButton extends StatelessWidget {
  const PiliBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MiuixIconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      child: const MiuixIcon(icon: Icons.arrow_back, size: 22),
    );
  }
}

/// Page scaffold following flutter-miuix skill: content is a padding builder.
class PiliMiuixPage extends StatelessWidget {
  const PiliMiuixPage({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.bottom,
    this.floatingActionButton,
    this.scrollBehavior,
    this.largeTitle = false,
    required this.content,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final MiuixExitUntilCollapsedScrollBehavior? scrollBehavior;
  final bool largeTitle;

  /// Receives scaffold padding and must apply it to the scroll/content root.
  final Widget Function(BuildContext context, EdgeInsets padding) content;

  Widget _buildTopBar(BuildContext context) {
    final title = this.title;
    if (title == null) return const SizedBox.shrink();

    final navIcon = leading ?? _autoBack(context);
    return Obx(() {
      final blur = UiStyleController.to.barBlur.value;
      if (largeTitle && scrollBehavior != null) {
        return MiuixTopAppBar(
          title: title,
          subtitle: subtitle ?? '',
          navigationIcon: navIcon,
          actions: actions,
          scrollBehavior: scrollBehavior,
          blurred: blur,
        );
      }
      final bar = MiuixSmallTopAppBar(
        title: title,
        subtitle: subtitle ?? '',
        navigationIcon: navIcon,
        actions: actions,
        color: blur ? Colors.transparent : null,
      );
      if (!blur) return bar;
      final colors = MiuixTheme.of(context).colors;
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(
            color: colors.surface.withValues(alpha: 0.78),
            child: bar,
          ),
        ),
      );
    });
  }

  static Widget? _autoBack(BuildContext context) {
    if (!Navigator.of(context).canPop()) return null;
    return const PiliBackButton();
  }

  @override
  Widget build(BuildContext context) {
    return MiuixScaffold(
      topBar: _buildTopBar(context),
      floatingActionButton: floatingActionButton,
      content: (padding) => content(context, padding),
    );
  }
}


/// Top-bar blur backdrop used when a page keeps a custom Material [AppBar].
class BarBlur extends StatelessWidget {
  const BarBlur({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final blur = UiStyleController.to.barBlur.value;
      if (!blur) return child;
      final colors = MiuixTheme.of(context).colors;
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(
            color: colors.surface.withValues(alpha: 0.78),
            child: child,
          ),
        ),
      );
    });
  }
}
