// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: prefer_initializing_formals

import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' hide PopScope;

import 'package:PiliPlus/utils/ui_style_controller.dart';

abstract class PopScopeState<T extends StatefulWidget> extends State<T>
    implements PopEntry<Object> {
  ModalRoute<dynamic>? _route;

  @override
  void onPopInvoked(bool didPop) {}

  @override
  late final ValueNotifier<bool> canPopNotifier;

  bool get initCanPop => true;

  @override
  void initState() {
    super.initState();
    canPopNotifier = ValueNotifier<bool>(initCanPop);
    _route = (Get.routing.route as ModalRoute)..registerPopEntry(this);
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    _route = null;
    canPopNotifier.dispose();
    super.dispose();
  }
}

// ignore: camel_case_types
typedef popScope = PopScope;

/// Predictive-back-aware PopScope.
///
/// When [UiStyleController.predictiveBack] is off, `canPop` is forced false so
/// the system will not run a predictive animation. If the caller intended
/// `canPop: true`, [onPopInvokedWithResult] compensates with a real pop and
/// returns — the re-entrant `didPop=true` delivers the caller callback.
class PopScope extends StatefulWidget {
  const PopScope({
    super.key,
    required this.child,
    this.canPop = true,
    required this.onPopInvokedWithResult,
  });

  final Widget child;

  final PopInvokedWithResultCallback<Object> onPopInvokedWithResult;

  final bool canPop;

  @override
  State<PopScope> createState() => _PopScopeState();
}

class _PopScopeState<T extends PopScope> extends PopScopeState<T> {
  Worker? _predictiveWorker;

  @override
  bool get initCanPop => _effectiveCanPop;

  bool get _predictive =>
      !Get.isRegistered<UiStyleController>() ||
      UiStyleController.to.predictiveBack.value;

  bool get _effectiveCanPop => widget.canPop && _predictive;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<UiStyleController>()) {
      _predictiveWorker = ever(UiStyleController.to.predictiveBack, (_) {
        if (mounted) {
          canPopNotifier.value = _effectiveCanPop;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _predictiveWorker?.dispose();
    _predictiveWorker = null;
    super.dispose();
  }

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (!didPop && widget.canPop && !_predictive) {
      // Predictive preview disabled: complete the pop the caller expected.
      // Navigator.pop re-enters onPopInvokedWithResult(didPop: true), which
      // delivers the caller callback — do not invoke it with false here.
      Navigator.of(context).pop();
      return;
    }
    widget.onPopInvokedWithResult(didPop, result);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    canPopNotifier.value = _effectiveCanPop;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
