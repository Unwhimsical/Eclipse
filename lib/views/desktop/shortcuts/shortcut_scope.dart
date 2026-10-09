import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/desktop/command_palette.dart';
import 'package:fl_clash/views/desktop/shortcuts/shortcut.dart';
import 'package:fl_clash/views/desktop/value_holder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The current desktop page registers its search focus, search clearing and
/// row deletion here so the global shortcuts can reach them.
final desktopSearchFocusNodeProvider = valueHolder<FocusNode?>(null);
final desktopClearSearchProvider = valueHolder<VoidCallback?>(null);
final desktopDeleteActionProvider = valueHolder<VoidCallback?>(null);

bool _focusIsTextInput() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context is! Element) return false;
  if (context.widget is EditableText) return true;
  var found = false;
  context.visitAncestorElements((element) {
    if (element.widget is EditableText) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Global in-app shortcut dispatcher (§3), desktop only. Digit keys stay
/// with [DesktopSideNav]; Space toggles the focused switch natively.
class DesktopShortcutScope extends ConsumerStatefulWidget {
  const DesktopShortcutScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DesktopShortcutScope> createState() =>
      _DesktopShortcutScopeState();
}

class _DesktopShortcutScopeState extends ConsumerState<DesktopShortcutScope> {
  @override
  void initState() {
    super.initState();
    unawaited(
      desktopShortcutStore.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      }),
    );
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _matches(SingleActivator activator, KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != activator.trigger) return false;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    bool has(LogicalKeyboardKey key) => keys.contains(key);
    final control =
        has(LogicalKeyboardKey.controlLeft) ||
        has(LogicalKeyboardKey.controlRight) ||
        has(LogicalKeyboardKey.metaLeft) ||
        has(LogicalKeyboardKey.metaRight);
    final alt =
        has(LogicalKeyboardKey.altLeft) || has(LogicalKeyboardKey.altRight);
    final shift =
        has(LogicalKeyboardKey.shiftLeft) || has(LogicalKeyboardKey.shiftRight);
    return activator.control == control &&
        activator.alt == alt &&
        activator.shift == shift;
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    for (final def in desktopShortcutDefs) {
      final binding = desktopShortcutStore.bindingFor(def);
      if (binding == null) continue;
      if (!_matches(binding, event)) continue;
      return _invoke(def.id);
    }
    return false;
  }

  bool _invoke(DesktopShortcutId id) {
    switch (id) {
      case DesktopShortcutId.openSettings:
        ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.settings);
        return true;
      case DesktopShortcutId.commandPalette:
        final context = globalState.navigatorKey.currentContext;
        if (context != null) showCommandPalette(context, ref);
        return true;
      case DesktopShortcutId.delayTest:
        _runDelayTest();
        return true;
      case DesktopShortcutId.focusSearch:
        if (_focusIsTextInput()) return false;
        if (!_isPageCurrent()) return false;
        ref.read(desktopSearchFocusNodeProvider)?.requestFocus();
        return true;
      case DesktopShortcutId.closeOrClear:
        return _handleEscape();
      case DesktopShortcutId.deleteRow:
        if (_focusIsTextInput()) return false;
        if (!_isPageCurrent()) return false;
        final action = ref.read(desktopDeleteActionProvider);
        if (action == null) return false;
        action();
        return true;
      case DesktopShortcutId.switchPage:
      case DesktopShortcutId.toggleRun:
        return false;
    }
  }

  bool _isPageCurrent() {
    final context = globalState.navigatorKey.currentContext;
    if (context == null) return true;
    final route = ModalRoute.of(context);
    return route == null || route.isCurrent;
  }

  bool _handleEscape() {
    final context = globalState.navigatorKey.currentContext;
    if (context == null) return false;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return true;
    }
    final clear = ref.read(desktopClearSearchProvider);
    if (clear == null) return false;
    clear();
    return true;
  }

  void _runDelayTest() {
    final groups = ref.read(currentGroupsStateProvider).value;
    final group = groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty);
    if (group == null) return;
    ref.read(proxiesActionProvider.notifier).delayTest(group.all);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
