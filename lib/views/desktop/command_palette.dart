import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/pages/config_page.dart';
import 'package:fl_clash/views/desktop/pages/settings_page.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// §3 command palette (Ctrl+K / Cmd+K): global search over nodes, configs,
/// rules, settings items and commands. The current page sets the scope.
void showCommandPalette(BuildContext context, WidgetRef ref) {
  final page = ref.read(currentPageLabelProvider);
  unawaited(
    showDialog(
      context: context,
      builder: (_) => _CommandPaletteDialog(initialPage: page),
    ),
  );
}

class _Entry {
  const _Entry({
    required this.title,
    required this.group,
    required this.icon,
    required this.run,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String group;
  final IconData icon;
  final void Function(WidgetRef ref) run;
}

class _CommandPaletteDialog extends ConsumerStatefulWidget {
  const _CommandPaletteDialog({required this.initialPage});

  final PageLabel initialPage;

  @override
  ConsumerState<_CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends ConsumerState<_CommandPaletteDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selected = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_Entry> _buildEntries() {
    final appLocalizations = context.appLocalizations;
    final entries = <_Entry>[];
    final commandsLabel = appLocalizations.scopeCommands;

    void go(PageLabel label) {
      ref.read(currentPageLabelProvider.notifier).toPage(label);
    }

    // Commands (always available).
    entries.addAll([
      _Entry(
        title: appLocalizations.toggleRun,
        group: commandsLabel,
        icon: Icons.power_settings_new_rounded,
        run: (ref) => ref.read(commonActionProvider.notifier).toggleRunning(),
      ),
      _Entry(
        title: appLocalizations.runDelayTest,
        group: commandsLabel,
        icon: Icons.speed_rounded,
        run: (ref) {
          final groups = ref.read(currentGroupsStateProvider).value;
          final group = groups.firstWhereOrNull(
            (g) => (g.now ?? '').isNotEmpty,
          );
          if (group != null) {
            ref.read(proxiesActionProvider.notifier).delayTest(group.all);
          }
        },
      ),
      for (final label in const [
        PageLabel.dashboard,
        PageLabel.config,
        PageLabel.modules,
        PageLabel.data,
        PageLabel.settings,
      ])
        _Entry(
          title: label.label,
          group: commandsLabel,
          icon: Icons.open_in_new_rounded,
          run: (ref) =>
              ref.read(currentPageLabelProvider.notifier).toPage(label),
        ),
    ]);

    // Configs.
    final profiles = ref.read(profilesProvider);
    for (final profile in profiles) {
      entries.add(
        _Entry(
          title: profile.realLabel,
          subtitle: appLocalizations.switchProfile,
          group: appLocalizations.config,
          icon: Icons.description_outlined,
          run: (ref) {
            ref.read(currentProfileIdProvider.notifier).value = profile.id;
            go(PageLabel.config);
          },
        ),
      );
    }

    // Nodes of the current profile.
    final groups = ref.read(currentGroupsStateProvider).value;
    for (final group in groups) {
      for (final proxy in group.all) {
        entries.add(
          _Entry(
            title: proxy.name,
            subtitle: group.name,
            group: appLocalizations.nodes,
            icon: Icons.hub_outlined,
            run: (ref) {
              ref.read(desktopConfigTabProvider.notifier).value = 0;
              ref
                  .read(proxiesActionProvider.notifier)
                  .changeProxy(groupName: group.name, proxyName: proxy.name);
              go(PageLabel.config);
            },
          ),
        );
      }
    }

    // Settings items.
    for (var i = 0; i < desktopSettingsGroups.length; i++) {
      entries.add(
        _Entry(
          title: desktopSettingsGroups[i].call(appLocalizations),
          group: appLocalizations.settings,
          icon: Icons.settings_outlined,
          run: (ref) {
            ref.read(desktopSettingsGroupProvider.notifier).value = i;
            go(PageLabel.settings);
          },
        ),
      );
    }

    // Scope by current page: matching-group entries first.
    final scopeGroup = switch (widget.initialPage) {
      PageLabel.config => appLocalizations.config,
      PageLabel.modules => appLocalizations.modules,
      PageLabel.settings => appLocalizations.settings,
      PageLabel.data => appLocalizations.data,
      _ => commandsLabel,
    };
    entries.sort((a, b) {
      final sa = a.group == scopeGroup ? 0 : 1;
      final sb = b.group == scopeGroup ? 0 : 1;
      return sa.compareTo(sb);
    });
    return entries;
  }

  List<_Entry> _filtered(List<_Entry> entries) {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return entries.take(12).toList();
    return entries
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              (e.subtitle?.toLowerCase().contains(q) ?? false),
        )
        .take(20)
        .toList();
  }

  void _runSelected(List<_Entry> entries) {
    if (entries.isEmpty || _selected >= entries.length) return;
    Navigator.of(context).pop();
    entries[_selected].run(ref);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final entries = _filtered(_buildEntries());
    if (_selected >= entries.length) _selected = 0;
    return Dialog(
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(DesktopThemeTokens.dialogRadius),
      ),
      backgroundColor: tokens?.bg2 ?? theme.colorScheme.surfaceContainerHigh,
      child: SizedBox(
        width: 560,
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.appLocalizations.commandPalette,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() => _selected = 0),
                onSubmitted: (_) => _runSelected(entries),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _PaletteList(
                entries: entries,
                selected: _selected,
                onSelect: (i) => setState(() => _selected = i),
                onRun: (i) {
                  setState(() => _selected = i);
                  _runSelected(entries);
                },
                onMove: (delta) => setState(() {
                  _selected = (_selected + delta).clamp(0, entries.length - 1);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteList extends StatelessWidget {
  const _PaletteList({
    required this.entries,
    required this.selected,
    required this.onSelect,
    required this.onRun,
    required this.onMove,
  });

  final List<_Entry> entries;
  final int selected;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onRun;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.appLocalizations.noSearchResult,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).extension<DesktopThemeTokens>()?.text3,
          ),
        ),
      );
    }
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveSelectionIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveSelectionIntent(-1),
      },
      child: Actions(
        actions: {
          _MoveSelectionIntent: CallbackAction<_MoveSelectionIntent>(
            onInvoke: (intent) => onMove(intent.delta),
          ),
        },
        child: Focus(
          autofocus: true,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              return _PaletteRow(
                entry: entry,
                selected: i == selected,
                onHover: () => onSelect(i),
                onTap: () => onRun(i),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MoveSelectionIntent extends Intent {
  const _MoveSelectionIntent(this.delta);

  final int delta;
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.entry,
    required this.selected,
    required this.onHover,
    required this.onTap,
  });

  final _Entry entry;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: selected
              ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
              : null,
          child: Row(
            spacing: 12,
            children: [
              Icon(
                entry.icon,
                size: 18,
                color: selected
                    ? accent
                    : (tokens?.text2 ?? theme.colorScheme.onSurfaceVariant),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.subtitle != null)
                      Text(
                        entry.subtitle!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              tokens?.text3 ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                entry.group,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
