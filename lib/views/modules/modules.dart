import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/module.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modules tab: imported `.sgmodule` files, in the style of
/// Shadowrocket's module list.
class ModulesView extends ConsumerStatefulWidget {
  const ModulesView({super.key});

  @override
  ConsumerState<ModulesView> createState() => _ModulesViewState();
}

class _ModulesViewState extends ConsumerState<ModulesView> {
  List<ModuleInfo> _modules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final modules = await moduleStore.list();
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
    final info = await ShadowrocketImport.importModule(
      ref,
      raw: raw,
      fileName: platformFile.name,
    );
    if (!mounted) return;
    if (info == null) {
      dialogs.showNotifier('未识别到有效模块', level: MessageLevel.warning);
      return;
    }
    dialogs.showNotifier('已导入模块：${info.name}', level: MessageLevel.success);
    await _refresh();
  }

  Future<void> _handleToggle(ModuleInfo info, bool enabled) async {
    await ShadowrocketImport.setModuleEnabled(ref, info, enabled);
    await _refresh();
  }

  Future<void> _handleDelete(ModuleInfo info) async {
    final confirmed = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: TextSpan(text: '删除模块「${info.name}」？'),
    );
    if (confirmed != true) return;
    if (info.enabled) {
      await ShadowrocketImport.setModuleEnabled(ref, info, false);
    }
    await moduleStore.delete(info.id);
    await _refresh();
  }

  void _showDetail(ModuleInfo info) {
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: info.name,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.desc.isNotEmpty) Text(info.desc),
              if (info.author != null) Text('作者：${info.author}'),
              const SizedBox(height: 8),
              Text('规则：${info.ruleCount}'),
              Text('Host：${info.hostCount}'),
              Text('URL 重写：${info.rewriteCount}'),
              Text('脚本：${info.scriptCount}'),
              if (info.needsMitm)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('含需要 MITM 解密的内容，暂以静态规则生效'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.modules,
      isLoading: _loading,
      floatingActionButton: FloatingActionButton(
        onPressed: _handleImport,
        child: const Icon(Icons.add),
      ),
      body: NullStatusSwitcher(
        isEmpty: _modules.isEmpty,
        nullStatus: NullStatus(
          label: '暂无模块，点击 + 导入 .sgmodule',
          illustration: NullStatusIllustration.profile,
        ),
        child: ListView.builder(
          itemCount: _modules.length,
          itemBuilder: (_, index) {
            final info = _modules[index];
            return ListItem(
              leading: Icon(
                Icons.extension,
                color: info.enabled ? null : context.colorScheme.outline,
              ),
              title: Text(
                info.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '规则 ${info.ruleCount} · 重写 ${info.rewriteCount} · 脚本 ${info.scriptCount}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: info.enabled,
                    onChanged: (value) => _handleToggle(info, value),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _handleDelete(info),
                  ),
                ],
              ),
              onTap: () => _showDetail(info),
            );
          },
        ),
      ),
    );
  }
}
