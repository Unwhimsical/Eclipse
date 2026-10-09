import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/desktop/shortcuts/shortcut.dart';
import 'package:fl_clash/views/desktop/value_holder.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Selected group index for the desktop settings page; the command palette
/// deep-links here.
final desktopSettingsGroupProvider = valueHolder(0);

/// Group titles, also used by the command palette.
final desktopSettingsGroups = <String Function(AppLocalizations)>[
  (l) => l.settingsGroupAppearance,
  (l) => l.settingsGroupNetwork,
  (l) => l.settingsGroupTray,
  (l) => l.settingsGroupShortcuts,
  (l) => l.settingsGroupAbout,
];

class _SettingItem {
  const _SettingItem({
    required this.title,
    required this.control,
    this.subtitle,
    this.keywords = const [],
  });

  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context, WidgetRef ref) control;
  final List<String> keywords;
}

class _SettingsGroup {
  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String Function(AppLocalizations) title;
  final List<_SettingItem> Function(BuildContext context, WidgetRef ref) items;
}

/// §2 desktop settings: 240px group nav left, max-width 640 form right,
/// searchable across groups.
class DesktopSettingsView extends ConsumerStatefulWidget {
  const DesktopSettingsView({super.key});

  @override
  ConsumerState<DesktopSettingsView> createState() =>
      _DesktopSettingsViewState();
}

class _DesktopSettingsViewState extends ConsumerState<DesktopSettingsView> {
  bool _searchOpen = false;
  String _query = '';
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  List<_SettingsGroup> get _groups => [
    _SettingsGroup(
      icon: Icons.palette_outlined,
      title: (l) => l.settingsGroupAppearance,
      items: _appearanceItems,
    ),
    _SettingsGroup(
      icon: Icons.lan_outlined,
      title: (l) => l.settingsGroupNetwork,
      items: _networkItems,
    ),
    _SettingsGroup(
      icon: Icons.notifications_outlined,
      title: (l) => l.settingsGroupTray,
      items: _trayItems,
    ),
    _SettingsGroup(
      icon: Icons.keyboard_outlined,
      title: (l) => l.settingsGroupShortcuts,
      items: _shortcutItems,
    ),
    _SettingsGroup(
      icon: Icons.info_outlined,
      title: (l) => l.settingsGroupAbout,
      items: _aboutItems,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final groupIndex = ref.watch(desktopSettingsGroupProvider);
    final groups = _groups;
    final q = _query.trim().toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.settings,
          actions: [
            if (_searchOpen)
              SizedBox(
                width: 220,
                child: TextField(
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: appLocalizations.searchSettings,
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            IconButton(
              tooltip: appLocalizations.searchSettings,
              onPressed: () {
                setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) _query = '';
                });
                if (_searchOpen) _searchFocus.requestFocus();
              },
              icon: const Icon(Icons.search_rounded),
            ),
            const DesktopRunSwitch(),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                SizedBox(
                  width: 240,
                  child: _GroupNav(
                    groups: groups,
                    selected: q.isEmpty ? groupIndex : -1,
                    onSelect: (i) =>
                        ref.read(desktopSettingsGroupProvider.notifier).value =
                            i,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: q.isEmpty
                          ? _GroupForm(
                              group:
                                  groups[groupIndex.clamp(
                                    0,
                                    groups.length - 1,
                                  )],
                            )
                          : _SearchResults(query: q, groups: groups),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupNav extends StatelessWidget {
  const _GroupNav({
    required this.groups,
    required this.selected,
    required this.onSelect,
  });

  final List<_SettingsGroup> groups;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return DesktopCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < groups.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(i),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: i == selected
                      ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(
                      groups[i].icon,
                      size: 20,
                      color: i == selected
                          ? accent
                          : (tokens?.text2 ??
                                theme.colorScheme.onSurfaceVariant),
                    ),
                    Expanded(
                      child: Text(
                        groups[i].title(appLocalizations),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: i == selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: i == selected
                              ? accent
                              : (tokens?.text1 ?? theme.colorScheme.onSurface),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupForm extends ConsumerWidget {
  const _GroupForm({required this.group});

  final _SettingsGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = group.items(context, ref);
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        itemBuilder: (_, i) => _SettingRow(item: items[i]),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.groups});

  final String query;
  final List<_SettingsGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final hits = <_SettingItem>[];
    for (final group in groups) {
      for (final item in group.items(context, ref)) {
        final haystack =
            '${item.title} ${item.subtitle ?? ''} ${item.keywords.join(' ')}'
                .toLowerCase();
        if (haystack.contains(query)) hits.add(item);
      }
    }
    if (hits.isEmpty) {
      return Center(
        child: Text(
          appLocalizations.noSettingsResult,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: hits.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
        itemBuilder: (_, i) => _SettingRow(item: hits[i]),
      ),
    );
  }
}

class _SettingRow extends ConsumerWidget {
  const _SettingRow({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          item.control(context, ref),
        ],
      ),
    );
  }
}

Widget _switchControl(bool value, ValueChanged<bool> onChanged) {
  return Switch(value: value, onChanged: onChanged);
}

List<_SettingItem> _appearanceItems(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final themeMode = ref.watch(themeSettingProvider.select((s) => s.themeMode));
  final locale = ref.watch(appSettingProvider.select((s) => s.locale));
  return [
    _SettingItem(
      title: appLocalizations.themeMode,
      control: (context, ref) => DropdownButton<ThemeMode>(
        value: themeMode,
        underline: const SizedBox.shrink(),
        items: [
          for (final mode in ThemeMode.values)
            DropdownMenuItem(
              value: mode,
              child: Text(_themeModeLabel(mode, appLocalizations)),
            ),
        ],
        onChanged: (mode) {
          if (mode == null) return;
          ref
              .read(themeSettingProvider.notifier)
              .update((s) => s.copyWith(themeMode: mode));
        },
      ),
    ),
    _SettingItem(
      title: appLocalizations.language,
      subtitle: _localeLabel(locale, appLocalizations),
      control: (context, ref) => OutlinedButton(
        onPressed: () => _pickLocale(context, ref),
        child: Text(appLocalizations.edit),
      ),
    ),
  ];
}

String _themeModeLabel(ThemeMode mode, AppLocalizations appLocalizations) {
  return switch (mode) {
    ThemeMode.system => appLocalizations.followSystem,
    ThemeMode.light => appLocalizations.light,
    ThemeMode.dark => appLocalizations.dark,
  };
}

String _localeLabel(String? locale, AppLocalizations appLocalizations) {
  if (locale == null) return appLocalizations.defaultText;
  return getLocaleForString(locale)?.label ?? locale;
}

Future<void> _pickLocale(BuildContext context, WidgetRef ref) async {
  final appLocalizations = context.appLocalizations;
  final current = ref.read(appSettingProvider).locale;
  final currentLocale = getLocaleForString(current);
  final options = [null, ...AppLocalizations.delegate.supportedLocales];
  await dialogs.showCommonDialog(
    child: CommonDialog(
      title: appLocalizations.language,
      child: SizedBox(
        width: 300,
        child: RadioGroup<Locale?>(
          groupValue: currentLocale,
          onChanged: (value) {
            ref
                .read(appSettingProvider.notifier)
                .update((state) => state.copyWith(locale: value?.toString()));
            Navigator.of(context).pop();
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (_, index) {
              final option = options[index];
              return RadioListTile<Locale?>(
                value: option,
                title: Text(
                  option == null ? appLocalizations.defaultText : option.label,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

List<_SettingItem> _networkItems(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final tun = ref.watch(patchClashConfigProvider.select((s) => s.tun.enable));
  final systemProxy = ref.watch(
    networkSettingProvider.select((s) => s.systemProxy),
  );
  return [
    _SettingItem(
      title: appLocalizations.tun,
      subtitle: appLocalizations.tunDesc,
      control: (_, ref) => _switchControl(tun, (_) {
        ref.read(systemActionProvider.notifier).updateTun();
      }),
    ),
    _SettingItem(
      title: appLocalizations.systemProxy,
      control: (_, ref) => _switchControl(systemProxy, (_) {
        ref.read(systemActionProvider.notifier).updateSystemProxy();
      }),
    ),
  ];
}

List<_SettingItem> _trayItems(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final setting = ref.watch(appSettingProvider);
  return [
    _SettingItem(
      title: appLocalizations.minimizeToTray,
      subtitle: appLocalizations.minimizeToTrayDesc,
      control: (_, ref) => _switchControl(setting.minimizeOnExit, (v) {
        ref
            .read(appSettingProvider.notifier)
            .update((s) => s.copyWith(minimizeOnExit: v));
      }),
    ),
    _SettingItem(
      title: appLocalizations.startup,
      subtitle: appLocalizations.autoLaunchDesc,
      control: (_, ref) => _switchControl(setting.autoLaunch, (v) {
        ref
            .read(appSettingProvider.notifier)
            .update((s) => s.copyWith(autoLaunch: v));
      }),
    ),
    _SettingItem(
      title: appLocalizations.trayTitle,
      control: (_, ref) => _switchControl(setting.showTrayTitle, (_) {
        ref.read(commonActionProvider.notifier).updateSpeedStatistics();
      }),
    ),
  ];
}

List<_SettingItem> _shortcutItems(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  return [
    for (final def in desktopShortcutDefs)
      _SettingItem(
        title: desktopShortcutLabel(def.id, appLocalizations),
        subtitle: def.rebindable ? null : appLocalizations.notRebindable,
        keywords: [def.id.name],
        control: (context, ref) => _ShortcutBindingControl(def: def),
      ),
    _SettingItem(
      title: appLocalizations.restoreDefaults,
      control: (context, ref) => OutlinedButton(
        onPressed: () => desktopShortcutStore.resetAll(),
        child: Text(appLocalizations.restoreDefaults),
      ),
    ),
  ];
}

class _ShortcutBindingControl extends StatefulWidget {
  const _ShortcutBindingControl({required this.def});

  final DesktopShortcutDef def;

  @override
  State<_ShortcutBindingControl> createState() =>
      _ShortcutBindingControlState();
}

class _ShortcutBindingControlState extends State<_ShortcutBindingControl> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: desktopShortcutStore,
      builder: (context, _) {
        final appLocalizations = context.appLocalizations;
        final theme = Theme.of(context);
        final tokens = theme.extension<DesktopThemeTokens>();
        final binding = desktopShortcutStore.bindingFor(widget.def);
        final label = binding == null
            ? _fixedHint(widget.def.id, appLocalizations)
            : describeActivator(binding);
        return OutlinedButton(
          onPressed: widget.def.rebindable ? () => _record(widget.def) : null,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: DesktopThemeTokens.monoFontFamily,
              fontFamilyFallback: DesktopThemeTokens.monoFontFamilyFallback,
              color: widget.def.rebindable
                  ? (tokens?.accent ?? theme.colorScheme.primary)
                  : (tokens?.text3 ?? theme.colorScheme.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }

  String _fixedHint(DesktopShortcutId id, AppLocalizations appLocalizations) {
    return switch (id) {
      DesktopShortcutId.switchPage => '1–5',
      DesktopShortcutId.toggleRun => appLocalizations.spaceKey,
      _ => appLocalizations.notRebindable,
    };
  }

  Future<void> _record(DesktopShortcutDef def) async {
    final appLocalizations = context.appLocalizations;
    final activator = await showDialog<SingleActivator>(
      context: context,
      builder: (_) => _ShortcutRecorderDialog(def: def),
    );
    if (activator == null || !mounted) return;
    await desktopShortcutStore.replaceBinding(def.id, activator);
    setState(() {});
    if (mounted) {
      context.showNotifier(
        appLocalizations.shortcutUpdated(
          desktopShortcutLabel(def.id, appLocalizations),
        ),
        level: MessageLevel.success,
      );
    }
  }
}

class _ShortcutRecorderDialog extends StatefulWidget {
  const _ShortcutRecorderDialog({required this.def});

  final DesktopShortcutDef def;

  @override
  State<_ShortcutRecorderDialog> createState() =>
      _ShortcutRecorderDialogState();
}

class _ShortcutRecorderDialogState extends State<_ShortcutRecorderDialog> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_capture);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_capture);
    super.dispose();
  }

  bool _capture(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return true;
    }
    if (_isModifier(event.logicalKey)) return false;
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    var control =
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight);
    final meta =
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    // Canonicalize Cmd to Ctrl on macOS so bindings roam across platforms.
    if (system.isMacOS && meta && !control) {
      control = true;
    }
    Navigator.of(context).pop(
      SingleActivator(
        event.logicalKey,
        control: control,
        alt:
            pressed.contains(LogicalKeyboardKey.altLeft) ||
            pressed.contains(LogicalKeyboardKey.altRight),
        shift:
            pressed.contains(LogicalKeyboardKey.shiftLeft) ||
            pressed.contains(LogicalKeyboardKey.shiftRight),
      ),
    );
    return true;
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: desktopShortcutLabel(widget.def.id, appLocalizations),
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(appLocalizations.pressKeys, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

List<_SettingItem> _aboutItems(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final version = globalState.packageInfo.version;
  return [
    _SettingItem(
      title: appLocalizations.appName,
      control: (context, ref) => SelectableText(appName),
    ),
    _SettingItem(
      title: appLocalizations.appVersion,
      control: (context, ref) => SelectableText(version),
    ),
  ];
}
