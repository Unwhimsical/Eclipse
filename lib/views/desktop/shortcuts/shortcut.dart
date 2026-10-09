import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// In-app desktop shortcuts (§3). Digit keys 1–5 are owned by
/// [DesktopSideNav] and Space toggles the focused switch natively; both are
/// listed as fixed. The rest are rebindable and persisted.
enum DesktopShortcutId {
  openSettings,
  commandPalette,
  delayTest,
  focusSearch,
  closeOrClear,
  deleteRow,
  switchPage,
  toggleRun,
}

class DesktopShortcutDef {
  const DesktopShortcutDef({
    required this.id,
    required this.defaultActivator,
    this.rebindable = true,
  });

  final DesktopShortcutId id;
  final SingleActivator? defaultActivator;
  final bool rebindable;
}

const desktopShortcutDefs = [
  DesktopShortcutDef(
    id: DesktopShortcutId.openSettings,
    defaultActivator: SingleActivator(LogicalKeyboardKey.comma, control: true),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.commandPalette,
    defaultActivator: SingleActivator(LogicalKeyboardKey.keyK, control: true),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.delayTest,
    defaultActivator: SingleActivator(LogicalKeyboardKey.keyR, control: true),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.focusSearch,
    defaultActivator: SingleActivator(LogicalKeyboardKey.slash),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.closeOrClear,
    defaultActivator: SingleActivator(LogicalKeyboardKey.escape),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.deleteRow,
    defaultActivator: SingleActivator(LogicalKeyboardKey.delete),
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.switchPage,
    defaultActivator: null,
    rebindable: false,
  ),
  DesktopShortcutDef(
    id: DesktopShortcutId.toggleRun,
    defaultActivator: null,
    rebindable: false,
  ),
];

String desktopShortcutLabel(
  DesktopShortcutId id,
  AppLocalizations appLocalizations,
) {
  return switch (id) {
    DesktopShortcutId.openSettings => appLocalizations.openSettings,
    DesktopShortcutId.commandPalette => appLocalizations.openCommandPalette,
    DesktopShortcutId.delayTest => appLocalizations.runDelayTest,
    DesktopShortcutId.focusSearch => appLocalizations.focusSearch,
    DesktopShortcutId.closeOrClear => appLocalizations.closeDialogOrClear,
    DesktopShortcutId.deleteRow => appLocalizations.deleteSelectedRow,
    DesktopShortcutId.switchPage => appLocalizations.switchPage,
    DesktopShortcutId.toggleRun => appLocalizations.toggleRun,
  };
}

/// Human-readable binding, e.g. "Ctrl+K". macOS shows ⌘.
String describeActivator(SingleActivator activator) {
  final parts = <String>[];
  final isMacOS = system.isMacOS;
  if (activator.control) parts.add(isMacOS ? '⌘' : 'Ctrl');
  if (activator.alt) parts.add(isMacOS ? '⌥' : 'Alt');
  if (activator.shift) parts.add(isMacOS ? '⇧' : 'Shift');
  if (activator.meta) parts.add(isMacOS ? '⌃' : 'Meta');
  parts.add(activator.trigger.keyLabel);
  return parts.join('+');
}

/// macOS uses Cmd where Windows/Linux use Ctrl (§3).
SingleActivator platformActivator(SingleActivator activator) {
  if (!system.isMacOS || !activator.control) return activator;
  return SingleActivator(
    activator.trigger,
    control: false,
    meta: true,
    shift: activator.shift,
    alt: activator.alt,
  );
}

Map<String, dynamic> _encodeActivator(SingleActivator activator) {
  return {
    'key': activator.trigger.keyId,
    'control': activator.control,
    'alt': activator.alt,
    'shift': activator.shift,
    'meta': activator.meta,
  };
}

SingleActivator? _decodeActivator(Map<String, dynamic> map) {
  try {
    final key = map['key'];
    if (key is! int) return null;
    return SingleActivator(
      LogicalKeyboardKey.findKeyByKeyId(key) ?? LogicalKeyboardKey.escape,
      control: map['control'] == true,
      alt: map['alt'] == true,
      shift: map['shift'] == true,
      meta: map['meta'] == true,
    );
  } catch (_) {
    return null;
  }
}

/// Persisted overrides for rebindable desktop shortcuts.
class DesktopShortcutStore extends ChangeNotifier {
  static const _key = 'desktopShortcuts.v1';

  Map<DesktopShortcutId, SingleActivator> _overrides = {};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      final raw = prefs?.getString(_key);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      final next = <DesktopShortcutId, SingleActivator>{};
      for (final entry in map.entries) {
        final id = DesktopShortcutId.values.asNameMap()[entry.key];
        final activator = entry.value is Map<String, dynamic>
            ? _decodeActivator(entry.value as Map<String, dynamic>)
            : null;
        if (id != null && activator != null) next[id] = activator;
      }
      _overrides = next;
    } catch (_) {
      // Corrupt bindings read as defaults.
    }
  }

  SingleActivator? bindingFor(DesktopShortcutDef def) {
    final override = _overrides[def.id];
    if (override != null) return platformActivator(override);
    final fallback = def.defaultActivator;
    return fallback == null ? null : platformActivator(fallback);
  }

  Future<void> setBinding(
    DesktopShortcutId id,
    SingleActivator activator,
  ) async {
    _overrides[id] = activator;
    notifyListeners();
    await _persist();
  }

  /// Rebind [id], clearing the same physical binding from other ids so two
  /// shortcuts never shadow each other.
  Future<void> replaceBinding(
    DesktopShortcutId id,
    SingleActivator activator,
  ) async {
    _overrides.removeWhere(
      (otherId, other) => otherId != id && _sameBinding(other, activator),
    );
    _overrides[id] = activator;
    notifyListeners();
    await _persist();
  }

  static bool _sameBinding(SingleActivator a, SingleActivator b) {
    return a.trigger == b.trigger &&
        a.control == b.control &&
        a.alt == b.alt &&
        a.shift == b.shift &&
        a.meta == b.meta;
  }

  Future<void> resetAll() async {
    _overrides = {};
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setString(
        _key,
        json.encode(
          _overrides.map(
            (id, activator) => MapEntry(id.name, _encodeActivator(activator)),
          ),
        ),
      );
    } catch (_) {
      // Binding persistence is best-effort.
    }
  }
}

final desktopShortcutStore = DesktopShortcutStore();
