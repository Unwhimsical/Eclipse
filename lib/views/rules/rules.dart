import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rules tab: global rule management plus `.conf` / `.sgmodule` rule import.
class RulesView extends ConsumerStatefulWidget {
  const RulesView({super.key});

  @override
  ConsumerState<RulesView> createState() => _RulesViewState();
}

class _RulesViewState extends ConsumerState<RulesView> {
  Future<void> _handleImportConf() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null || !mounted) return;
    final bytes = await platformFile.readBytes();
    final content = String.fromCharCodes(bytes);
    final conf = parseConf(content);
    if (conf.rules.isEmpty) {
      dialogs.showNotifier('.conf 中没有找到规则', level: MessageLevel.warning);
      return;
    }
    final count = await ShadowrocketImport.importRules(ref, conf.rules);
    if (!mounted) return;
    dialogs.showNotifier('已导入 $count 条规则', level: MessageLevel.success);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.rules,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_open),
          tooltip: '导入 .conf 规则',
          onPressed: _handleImportConf,
        ),
      ],
      body: const AddedRulesView(),
    );
  }
}
