import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'module_argument_editor.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/module.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Module list without a scaffold, in Shadowrocket's module-list style.
/// Embedded in the Config tab next to the profile list.
class ModuleListView extends ConsumerStatefulWidget {
  const ModuleListView({
    super.key,
    this.reorderable = false,
    this.showHeader = true,
  });

  /// Drag-reorder rows. Off when embedded in another scroll view.
  final bool reorderable;

  final bool showHeader;

  @override
  ModuleListViewState createState() => ModuleListViewState();
}

class ModuleListViewState extends ConsumerState<ModuleListView> {
  List<ModuleInfo> _modules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
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
    });
  }

  Future<void> _handleImport() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null || !mounted) return;
    final bytes = await platformFile.readBytes();
    final raw = String.fromCharCodes(bytes);
    await _importModuleContent(raw, platformFile.name);
  }

  Future<void> _handleImportFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        hintText: 'https://example.com/module.sgmodule',
        value: '',
        keyboardType: TextInputType.url,
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url == null || url.isEmpty || !mounted) return;
    final info = await globalState.safeRun(
      () => ShadowrocketImport.importModuleFromUrl(ref, url: url),
    );
    if (!mounted) return;
    if (info == null) {
      dialogs.showNotifier(
        appLocalizations.moduleDownloadFailed,
        level: MessageLevel.warning,
      );
      return;
    }
    dialogs.showNotifier(
      appLocalizations.moduleImported(info.name),
      level: MessageLevel.success,
    );
    await _refresh();
  }

  Future<void> _importModuleContent(String raw, String? fileName) async {
    final info = await ShadowrocketImport.importModule(
      ref,
      raw: raw,
      fileName: fileName,
    );
    if (!mounted) return;
    if (info == null) {
      dialogs.showNotifier(
        currentAppLocalizations.moduleInvalid,
        level: MessageLevel.warning,
      );
      return;
    }
    dialogs.showNotifier(
      currentAppLocalizations.moduleImported(info.name),
      level: MessageLevel.success,
    );
    await _refresh();
  }

  void showImportMenu() {
    final appLocalizations = context.appLocalizations;
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: appLocalizations.importModule,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.file_open),
              title: Text(appLocalizations.importModuleFromFile),
              onTap: () {
                Navigator.of(context).pop();
                _handleImport();
              },
            ),
            ListItem(
              leading: const Icon(Icons.link),
              title: Text(appLocalizations.importFromUrl),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportFromUrl();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggle(ModuleInfo info, bool enabled) async {
    await ShadowrocketImport.setModuleEnabled(ref, info, enabled);
    await _refresh();
  }

  Future<void> _handleDelete(ModuleInfo info) async {
    final confirmed = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: TextSpan(
        text: currentAppLocalizations.deleteModuleConfirm(info.name),
      ),
    );
    if (confirmed != true) return;
    if (info.enabled) {
      await ShadowrocketImport.setModuleEnabled(ref, info, false);
    }
    await moduleStore.delete(info.id);
    await _refresh();
  }

  Future<void> _showDetail(ModuleInfo info) async {
    final appLocalizations = context.appLocalizations;
    final raw = await moduleStore.readRaw(info.id);
    final declared = raw == null ? null : parseSgmodule(raw);
    final args = declared?.arguments ?? const <ModuleArgument>[];
    if (!mounted) return;
    unawaited(
      dialogs.showCommonDialog(
        child: CommonDialog(
          title: info.name,
          actions: [
            if (args.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final saved = await dialogs.showCommonDialog<bool>(
                    child: ModuleArgumentEditorDialog(
                      info: info,
                      arguments: args,
                      descriptions: declared?.argumentDescriptions ?? const {},
                    ),
                  );
                  if (saved == true) {
                    await _refresh();
                  }
                },
                child: Text(appLocalizations.editArguments),
              ),
          ],
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.desc.isNotEmpty) Text(info.desc),
                if (info.author != null)
                  Text(appLocalizations.moduleAuthor(info.author!)),
                const SizedBox(height: 8),
                Text(appLocalizations.moduleRuleCount(info.ruleCount)),
                Text(appLocalizations.moduleHostCount(info.hostCount)),
                Text(appLocalizations.moduleRewriteCount(info.rewriteCount)),
                Text(appLocalizations.moduleScriptCount(info.scriptCount)),
                if (info.needsMitm)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(appLocalizations.moduleMitmNote),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      final item = _modules.removeAt(oldIndex);
      _modules.insert(newIndex, item);
    });
    await moduleStore.saveOrder(_modules);
  }

  Widget _buildRow(ModuleInfo info, int index) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      key: ValueKey(info.id),
      leading: Icon(
        Icons.extension_outlined,
        color: info.enabled ? null : context.colorScheme.outline,
      ),
      title: Text(info.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        appLocalizations.moduleStatsSummary(
          info.ruleCount,
          info.rewriteCount,
          info.scriptCount,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: info.enabled,
            onChanged: (value) => _handleToggle(info, value),
          ),
          if (widget.reorderable)
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle_outlined),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: appLocalizations.delete,
            onPressed: () => _handleDelete(info),
          ),
        ],
      ),
      onTap: () => _showDetail(info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final emptyStatus = NullStatus(
      label: appLocalizations.noModulesDesc,
      illustration: NullStatusIllustration.profile,
    );
    final Widget listView = widget.reorderable
        ? ReorderableListView.builder(
            itemCount: _modules.length,
            onReorderItem: _handleReorder,
            itemBuilder: (_, index) => _buildRow(_modules[index], index),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modules.length,
            itemBuilder: (_, index) => _buildRow(_modules[index], index),
          );
    final Widget body;
    if (_loading) {
      body = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (widget.reorderable) {
      body = NullStatusSwitcher(
        isEmpty: _modules.isEmpty,
        nullStatus: emptyStatus,
        child: listView,
      );
    } else {
      // No animated switcher here: StackFit.expand needs bounded height.
      body = _modules.isEmpty ? emptyStatus : listView;
    }
    if (!widget.showHeader) return body;
    return EclipseSection(
      title: appLocalizations.modules,
      trailing: IconButton(
        icon: const Icon(Icons.add),
        tooltip: appLocalizations.importModule,
        onPressed: showImportMenu,
      ),
      children: [body],
    );
  }
}

/// Full-page module management.
class ModulesView extends ConsumerStatefulWidget {
  const ModulesView({super.key});

  @override
  ConsumerState<ModulesView> createState() => _ModulesViewState();
}

class _ModulesViewState extends ConsumerState<ModulesView> {
  final _listKey = GlobalKey<ModuleListViewState>();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.modules,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _listKey.currentState?.showImportMenu(),
        tooltip: appLocalizations.importModule,
        child: const Icon(Icons.add),
      ),
      body: ModuleListView(key: _listKey, reorderable: true, showHeader: false),
    );
  }
}
