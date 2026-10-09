import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/modules/module_argument_editor.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// §2 desktop modules page (replaces the placeholder): 320px module list
/// with P0 drag-sort (order = rule priority) left, detail right.
/// Header: [search][add module][update all].
class DesktopModulesView extends ConsumerStatefulWidget {
  const DesktopModulesView({super.key});

  @override
  ConsumerState<DesktopModulesView> createState() => _DesktopModulesViewState();
}

class _DesktopModulesViewState extends ConsumerState<DesktopModulesView> {
  List<ModuleInfo> _modules = [];
  bool _loading = true;
  bool _searchOpen = false;
  String _query = '';
  String? _selectedId;
  bool _updatingAll = false;
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    List<ModuleInfo> modules = const [];
    try {
      modules = await moduleStore.list();
    } catch (_) {
      // Storage failures leave an empty list instead of a stuck spinner.
    }
    if (!mounted) return;
    setState(() {
      _modules = modules;
      _loading = false;
      if (_selectedId != null && modules.every((m) => m.id != _selectedId)) {
        _selectedId = null;
      }
      _selectedId ??= modules.firstOrNull?.id;
    });
  }

  List<ModuleInfo> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return _modules;
    return _modules
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.desc.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    final filtered = _filtered;
    final item = filtered[oldIndex];
    final next = List<ModuleInfo>.from(_modules);
    next.remove(item);
    final target = filtered[newIndex];
    final at = next.indexOf(target);
    next.insert(newIndex > oldIndex ? at + 1 : at, item);
    setState(() => _modules = next);
    await moduleStore.saveOrder(next);
    // List order is rule priority; re-apply so the core picks it up.
    ref.read(setupActionProvider.notifier).applyProfileDebounce();
  }

  Future<void> _handleImport() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null || !mounted) return;
    final bytes = await platformFile.readBytes();
    final raw = String.fromCharCodes(bytes);
    await globalState.safeRun(() async {
      final info = await ShadowrocketImport.importModule(
        ref,
        raw: raw,
        fileName: platformFile.name,
      );
      if (info != null && mounted) {
        setState(() => _selectedId = info.id);
      }
    });
    await _refresh();
  }

  Future<void> _handleImportFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.importFromUrl,
        labelText: appLocalizations.url,
        hintText: 'https://example.com/module.sgmodule',
        value: '',
      ),
    );
    if (url == null || url.isEmpty || !mounted) return;
    await globalState.safeRun(() async {
      final info = await ShadowrocketImport.importModuleFromUrl(ref, url: url);
      if (info != null && mounted) {
        setState(() => _selectedId = info.id);
      }
    });
    await _refresh();
  }

  void _showImportMenu() {
    final appLocalizations = context.appLocalizations;
    unawaited(
      dialogs.showCommonDialog(
        child: CommonDialog(
          title: appLocalizations.addModule,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListItem(
                leading: const Icon(Icons.file_open_outlined),
                title: Text(appLocalizations.importModuleFromFile),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleImport();
                },
              ),
              ListItem(
                leading: const Icon(Icons.link_rounded),
                title: Text(appLocalizations.importFromUrl),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleImportFromUrl();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateAll() async {
    if (_updatingAll) return;
    final targets = _modules
        .where((m) => (m.sourceUrl ?? '').isNotEmpty)
        .toList();
    if (targets.isEmpty) {
      context.showNotifier(
        context.appLocalizations.noUpdatableModules,
        level: MessageLevel.info,
      );
      return;
    }
    setState(() => _updatingAll = true);
    try {
      var done = 0;
      for (final module in targets) {
        try {
          await ShadowrocketImport.importModuleFromUrl(
            ref,
            url: module.sourceUrl!,
          );
          done++;
        } catch (_) {
          // One failing module must not block the rest.
        }
      }
      if (mounted) {
        context.showNotifier(
          context.appLocalizations.modulesUpdated(done, targets.length),
          level: MessageLevel.success,
        );
      }
    } finally {
      if (mounted) setState(() => _updatingAll = false);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final selected = _modules.where((m) => m.id == _selectedId).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.modules,
          actions: [
            if (_searchOpen)
              SizedBox(
                width: 220,
                child: TextField(
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: appLocalizations.searchModules,
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            IconButton(
              tooltip: appLocalizations.search,
              onPressed: () {
                setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) _query = '';
                });
                if (_searchOpen) _searchFocus.requestFocus();
              },
              icon: const Icon(Icons.search_rounded),
            ),
            FilledButton.icon(
              onPressed: _showImportMenu,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(appLocalizations.addModule),
            ),
            OutlinedButton.icon(
              onPressed: _updatingAll ? null : _handleUpdateAll,
              icon: _updatingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CommonCircleLoading(),
                    )
                  : const Icon(Icons.system_update_alt_rounded, size: 18),
              label: Text(appLocalizations.updateAll),
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
                  width: 320,
                  child: _ModuleListPanel(
                    loading: _loading,
                    modules: _filtered,
                    selectedId: _selectedId,
                    hasAny: _modules.isNotEmpty,
                    query: _query,
                    onSelect: (id) => setState(() => _selectedId = id),
                    onReorder: _handleReorder,
                    onAdd: _showImportMenu,
                  ),
                ),
                Expanded(
                  child: selected == null
                      ? _ModuleEmptyDetail(
                          hasModules: _modules.isNotEmpty,
                          query: _query,
                          onAdd: _showImportMenu,
                        )
                      : _ModuleDetail(
                          key: ValueKey(selected.id),
                          info: selected,
                          onChanged: _refresh,
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

class _ModuleListPanel extends StatelessWidget {
  const _ModuleListPanel({
    required this.loading,
    required this.modules,
    required this.selectedId,
    required this.hasAny,
    required this.query,
    required this.onSelect,
    required this.onReorder,
    required this.onAdd,
  });

  final bool loading;
  final List<ModuleInfo> modules;
  final String? selectedId;
  final bool hasAny;
  final String query;
  final ValueChanged<String> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final tokens = Theme.of(context).extension<DesktopThemeTokens>();
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              appLocalizations.modules,
              style: tokens?.groupTitleStyle.copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (loading) {
                  return const Center(child: CommonCircleLoading());
                }
                if (!hasAny) {
                  return _ModuleEmptyState(
                    title: appLocalizations.noModules,
                    subtitle: appLocalizations.noModulesDesc,
                    actionLabel: appLocalizations.addModule,
                    onAction: onAdd,
                  );
                }
                if (modules.isEmpty) {
                  return _ModuleEmptyState(
                    title: appLocalizations.noSearchResult,
                    actionLabel: appLocalizations.clearSearch,
                    onAction: () {},
                  );
                }
                return SingleChildScrollView(
                  child: DesktopDragList<ModuleInfo>(
                    items: modules,
                    itemExtent: 64,
                    onReorder: onReorder,
                    itemBuilder: (context, module, index, handle) {
                      return _ModuleRow(
                        info: module,
                        selected: module.id == selectedId,
                        handle: handle,
                        onTap: () => onSelect(module.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleEmptyState extends StatelessWidget {
  const _ModuleEmptyState({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.extension_outlined, size: 44, color: text3),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: text3),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(color: text3),
                textAlign: TextAlign.center,
              ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 4),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleEmptyDetail extends StatelessWidget {
  const _ModuleEmptyDetail({
    required this.hasModules,
    required this.query,
    required this.onAdd,
  });

  final bool hasModules;
  final String query;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (!hasModules) {
      return _ModuleEmptyState(
        title: appLocalizations.noModules,
        subtitle: appLocalizations.noModulesDesc,
        actionLabel: appLocalizations.addModule,
        onAction: onAdd,
      );
    }
    return _ModuleEmptyState(
      title: appLocalizations.noSearchResult,
      actionLabel: query.isEmpty ? null : appLocalizations.clearSearch,
      onAction: query.isEmpty ? null : () {},
    );
  }
}

class _ModuleRow extends ConsumerStatefulWidget {
  const _ModuleRow({
    required this.info,
    required this.selected,
    required this.handle,
    required this.onTap,
  });

  final ModuleInfo info;
  final bool selected;
  final Widget handle;
  final VoidCallback onTap;

  @override
  ConsumerState<_ModuleRow> createState() => _ModuleRowState();
}

class _ModuleRowState extends ConsumerState<_ModuleRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final info = widget.info;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onSecondaryTapUp: (details) =>
              _showRowMenu(context, details.globalPosition),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: widget.selected
                  ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                  : _hover
                  ? DesktopThemeTokens.controlHoverOverlay
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 4,
              children: [
                widget.handle,
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: info.enabled
                        ? (tokens?.success ?? theme.colorScheme.primary)
                        : Colors.transparent,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        info.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.selected
                              ? accent
                              : (tokens?.text1 ?? theme.colorScheme.onSurface),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${info.ruleCount} ${context.appLocalizations.rules}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              tokens?.text3 ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showRowMenu(BuildContext context, Offset position) async {
    final appLocalizations = context.appLocalizations;
    final info = widget.info;
    final action = await showDesktopMenu<VoidCallback>(
      context: context,
      position: position,
      items: [
        DesktopMenuItem(
          label: info.enabled
              ? appLocalizations.disableAction
              : appLocalizations.enableAction,
          icon: info.enabled
              ? Icons.toggle_off_outlined
              : Icons.toggle_on_outlined,
          value: () => _handleToggle(!info.enabled),
        ),
        DesktopMenuItem(
          label: appLocalizations.update,
          icon: Icons.system_update_alt_rounded,
          value: () => _handleUpdate(context),
        ),
        const DesktopMenuDivider(),
        DesktopMenuItem(
          label: appLocalizations.delete,
          icon: Icons.delete_outlined,
          danger: true,
          value: () => _handleDelete(context),
        ),
      ],
    );
    action?.call();
  }

  Future<void> _handleToggle(bool enabled) async {
    await ShadowrocketImport.setModuleEnabled(ref, widget.info, enabled);
    await _refreshParent();
  }

  Future<void> _handleUpdate(BuildContext context) async {
    final info = widget.info;
    final url = info.sourceUrl;
    if (url != null && url.isNotEmpty) {
      await globalState.safeRun(
        () => ShadowrocketImport.importModuleFromUrl(ref, url: url),
      );
    } else {
      final appLocalizations = context.appLocalizations;
      final picked = await globalState.safeRun(picker.pickerFile);
      if (picked == null) return;
      final bytes = await picked.readBytes();
      final raw = String.fromCharCodes(bytes);
      await globalState.safeRun(
        () => ShadowrocketImport.updateModule(ref, info.id, raw),
      );
      if (context.mounted) {
        context.showNotifier(
          appLocalizations.moduleUpdated(info.name),
          level: MessageLevel.success,
        );
      }
    }
    await _refreshParent();
  }

  Future<void> _handleDelete(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final info = widget.info;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.confirmDeleteTitle,
      message: '${info.name}\n${appLocalizations.confirmDeleteMessage}',
      confirmLabel: appLocalizations.delete,
      danger: true,
    );
    if (!confirmed) return;
    if (info.enabled) {
      await ShadowrocketImport.setModuleEnabled(ref, info, false);
    }
    await moduleStore.delete(info.id);
    await _refreshParent();
  }

  Future<void> _refreshParent() async {
    final state = context.findAncestorStateOfType<_DesktopModulesViewState>();
    await state?._refresh();
  }
}

class _ModuleDetail extends ConsumerStatefulWidget {
  const _ModuleDetail({super.key, required this.info, required this.onChanged});

  final ModuleInfo info;
  final Future<void> Function() onChanged;

  @override
  ConsumerState<_ModuleDetail> createState() => _ModuleDetailState();
}

class _ModuleDetailState extends ConsumerState<_ModuleDetail> {
  Future<void> _handleToggle(bool enabled) async {
    await ShadowrocketImport.setModuleEnabled(ref, widget.info, enabled);
    await widget.onChanged();
  }

  Future<void> _handleArguments() async {
    final raw = await moduleStore.readRaw(widget.info.id);
    if (raw == null || !mounted) return;
    final args = scanModuleArguments(raw);
    if (args.isEmpty || !mounted) return;
    final changed = await dialogs.showCommonDialog<bool>(
      child: ModuleArgumentEditorDialog(info: widget.info, arguments: args),
    );
    if (changed == true) await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final info = widget.info;
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        info.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (info.desc.isNotEmpty)
                        Text(
                          info.desc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                tokens?.text2 ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (info.author?.isNotEmpty == true)
                        Text(
                          '${appLocalizations.moduleAuthor}: ${info.author}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                tokens?.text3 ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(value: info.enabled, onChanged: _handleToggle),
              ],
            ),
            _DetailSection(
              title: appLocalizations.moduleParams,
              trailing: FutureBuilder<String?>(
                future: moduleStore.readRaw(info.id),
                builder: (context, snapshot) {
                  final raw = snapshot.data;
                  final args = raw == null
                      ? const <ModuleArgument>[]
                      : scanModuleArguments(raw);
                  if (args.isEmpty) return const SizedBox.shrink();
                  return OutlinedButton(
                    onPressed: _handleArguments,
                    child: Text(appLocalizations.edit),
                  );
                },
              ),
              child: Builder(
                builder: (context) {
                  final values = info.argumentValues;
                  if (values.isEmpty) {
                    return Text(
                      appLocalizations.noModuleParams,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    spacing: 8,
                    children: [
                      for (final entry in values.entries)
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 160,
                              child: Text(
                                entry.key,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      tokens?.text2 ??
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
            _DetailSection(
              title: appLocalizations.moduleRuleStats,
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _Stat(
                    label: appLocalizations.rules,
                    value: '${info.ruleCount}',
                  ),
                  _Stat(
                    label: appLocalizations.hosts,
                    value: '${info.hostCount}',
                  ),
                  _Stat(
                    label: appLocalizations.rewrites,
                    value: '${info.rewriteCount}',
                  ),
                  _Stat(
                    label: appLocalizations.scripts,
                    value: '${info.scriptCount}',
                  ),
                ],
              ),
            ),
            Row(
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _ModuleRowHelper.update(
                    context,
                    ref,
                    info,
                  ).then((_) => widget.onChanged()),
                  icon: const Icon(Icons.system_update_alt_rounded, size: 18),
                  label: Text(appLocalizations.update),
                ),
                OutlinedButton.icon(
                  onPressed: () => _ModuleRowHelper.delete(
                    context,
                    ref,
                    info,
                  ).then((_) => widget.onChanged()),
                  icon: Icon(
                    Icons.delete_outlined,
                    size: 18,
                    color: tokens?.danger ?? theme.colorScheme.error,
                  ),
                  label: Text(
                    appLocalizations.delete,
                    style: TextStyle(
                      color: tokens?.danger ?? theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared update/delete flows used by the detail buttons (the row menu has
/// its own copies bound to row state).
class _ModuleRowHelper {
  static Future<void> update(
    BuildContext context,
    WidgetRef ref,
    ModuleInfo info,
  ) async {
    final url = info.sourceUrl;
    if (url != null && url.isNotEmpty) {
      await globalState.safeRun(
        () => ShadowrocketImport.importModuleFromUrl(ref, url: url),
      );
    } else {
      final picked = await globalState.safeRun(picker.pickerFile);
      if (picked == null) return;
      final bytes = await picked.readBytes();
      await globalState.safeRun(
        () => ShadowrocketImport.updateModule(
          ref,
          info.id,
          String.fromCharCodes(bytes),
        ),
      );
    }
  }

  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    ModuleInfo info,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.confirmDeleteTitle,
      message: '${info.name}\n${appLocalizations.confirmDeleteMessage}',
      confirmLabel: appLocalizations.delete,
      danger: true,
    );
    if (!confirmed) return;
    if (info.enabled) {
      await ShadowrocketImport.setModuleEnabled(ref, info, false);
    }
    await moduleStore.delete(info.id);
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesktopThemeTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: tokens?.groupTitleStyle.copyWith(fontSize: 13),
              ),
            ),
            if (trailing case final value?) value,
          ],
        ),
        child,
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: DesktopThemeTokens.kpiFontFeatures,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
