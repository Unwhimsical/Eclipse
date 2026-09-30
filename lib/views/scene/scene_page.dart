import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

String _triggerLabel(AppLocalizations l, SceneTriggerType type) {
  return switch (type) {
    SceneTriggerType.ssid => l.sceneTriggerSsid,
    SceneTriggerType.cellular => l.sceneTriggerCellular,
    SceneTriggerType.fallback => l.sceneTriggerFallback,
  };
}

String _profileLabel(Profile profile) {
  final label = profile.label.trim();
  return label.isEmpty ? profile.id.toString() : label;
}

String _sceneSummary(AppLocalizations l, Scene scene, Profile? profile) {
  final trigger = scene.triggerType == SceneTriggerType.ssid
      ? '${l.sceneTriggerSsid}: ${scene.ssid ?? ''}'
      : _triggerLabel(l, scene.triggerType);
  final target = profile == null ? l.sceneNoSwitch : _profileLabel(profile);
  return '$trigger · $target';
}

class SceneView extends ConsumerWidget {
  const SceneView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final scenes = ref.watch(sceneListProvider);
    return CommonScaffold(
      title: appLocalizations.sceneMode,
      actions: [
        IconButton(
          tooltip: appLocalizations.addScene,
          icon: const Icon(Icons.add),
          onPressed: () => _openEditDialog(context, null),
        ),
      ],
      body: Column(
        children: [
          ConfigToggleItem(
            title: (l) => l.sceneMode,
            subtitle: (l) => l.sceneModeDesc,
            selector: sceneModeEnabledProvider,
            onChanged: (ref, value) => ref
                .read(sceneModeEnabledProvider.notifier)
                .update((_) => value),
          ),
          if (system.isIOS)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('iOS 仅在 App 处于前台时检测网络变化并切换场景'),
            ),
          scenes.when(
            data: (list) {
              if (list.isEmpty) {
                return ListTile(title: Text(appLocalizations.sceneEmpty));
              }
              final profiles = ref.watch(profilesProvider);
              return Column(
                children: [
                  for (final scene in list)
                    ListTile(
                      title: Text(scene.name),
                      subtitle: Text(
                        _sceneSummary(
                          appLocalizations,
                          scene,
                          profiles
                              .where((p) => p.id == scene.targetProfileId)
                              .firstOrNull,
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: appLocalizations.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, ref, scene),
                      ),
                      onTap: () => _openEditDialog(context, scene),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => ListTile(title: Text(e.toString())),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, Scene? scene) async {
    await dialogs.showCommonDialog(
      context: context,
      child: _SceneEditDialog(scene: scene),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Scene scene,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: appLocalizations.delete,
      message: TextSpan(text: appLocalizations.sceneDeleteConfirm),
    );
    if (confirmed == true) {
      await ref.read(sceneListProvider.notifier).deleteScene(scene.id);
    }
  }
}

class _SceneEditDialog extends ConsumerStatefulWidget {
  final Scene? scene;

  const _SceneEditDialog({this.scene});

  @override
  ConsumerState<_SceneEditDialog> createState() => _SceneEditDialogState();
}

class _SceneEditDialogState extends ConsumerState<_SceneEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _ssidController;
  late SceneTriggerType _triggerType;
  int? _targetProfileId;
  Mode? _mode;
  String? _targetProxy;

  @override
  void initState() {
    super.initState();
    final scene = widget.scene;
    _nameController = TextEditingController(text: scene?.name ?? '');
    _ssidController = TextEditingController(text: scene?.ssid ?? '');
    _triggerType = scene?.triggerType ?? SceneTriggerType.ssid;
    _targetProfileId = scene?.targetProfileId;
    _mode = scene?.mode;
    _targetProxy = scene?.targetProxy;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ssidController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameController.text.trim().isNotEmpty &&
      (_triggerType != SceneTriggerType.ssid ||
          _ssidController.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final clashConfig = _targetProfileId == null
        ? null
        : ref.watch(clashConfigProvider(_targetProfileId!)).value;
    final proxyNames = clashConfig?.proxies.map((p) => p.name).toList() ?? [];
    return CommonDialog(
      title: widget.scene == null
          ? appLocalizations.addScene
          : appLocalizations.editScene,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _valid ? _save : null,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: appLocalizations.name),
            onChanged: (_) => setState(() {}),
          ),
          ListItem.options(
            title: Text(appLocalizations.sceneTrigger),
            dialogTitle: appLocalizations.sceneTrigger,
            options: SceneTriggerType.values,
            value: _triggerType,
            textBuilder: (type) => _triggerLabel(appLocalizations, type),
            onChanged: (type) {
              if (type != null) setState(() => _triggerType = type);
            },
          ),
          if (_triggerType == SceneTriggerType.ssid)
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(
                labelText: appLocalizations.sceneTriggerSsid,
                hintText: appLocalizations.sceneSsidHint,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ListItem<int?>.options(
            title: Text(appLocalizations.sceneTargetProfile),
            dialogTitle: appLocalizations.sceneTargetProfile,
            options: [null, for (final p in profiles) p.id],
            value: _targetProfileId,
            textBuilder: (id) => id == null
                ? appLocalizations.sceneNoSwitch
                : _profileLabel(profiles.firstWhere((p) => p.id == id)),
            onChanged: (id) => setState(() {
              _targetProfileId = id;
              _targetProxy = null;
            }),
          ),
          ListItem<Mode?>.options(
            title: Text(appLocalizations.sceneTargetMode),
            dialogTitle: appLocalizations.sceneTargetMode,
            options: [null, ...Mode.values],
            value: _mode,
            textBuilder: (mode) => switch (mode) {
              null => appLocalizations.sceneKeepCurrent,
              Mode.rule => appLocalizations.rule,
              Mode.global => appLocalizations.global,
              Mode.direct => appLocalizations.direct,
            },
            onChanged: (mode) => setState(() => _mode = mode),
          ),
          ListItem<String?>.options(
            title: Text(appLocalizations.sceneTargetProxy),
            dialogTitle: appLocalizations.sceneTargetProxy,
            options: [null, ...proxyNames],
            value: _targetProxy,
            textBuilder: (name) => name ?? appLocalizations.sceneKeepCurrent,
            onChanged: (name) => setState(() => _targetProxy = name),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final scenes = ref.read(sceneListProvider).value ?? const <Scene>[];
    final order =
        widget.scene?.order ??
        (scenes.map((s) => s.order).fold<int>(0, (a, b) => a > b ? a : b) + 1);
    final scene = Scene(
      id: widget.scene?.id ?? 0,
      name: _nameController.text.trim(),
      triggerType: _triggerType,
      ssid: _triggerType == SceneTriggerType.ssid
          ? _ssidController.text.trim()
          : null,
      targetProfileId: _targetProfileId,
      mode: _mode,
      targetProxy: _targetProfileId == null ? null : _targetProxy,
      order: order,
    );
    await ref.read(sceneListProvider.notifier).putScene(scene);
    if (mounted) Navigator.of(context).pop();
  }
}
