import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
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
    await _importConfContent(content);
  }

  Future<void> _handleImportConfFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        hintText: 'https://example.com/rules.conf',
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
    final content = await globalState.safeRun(
      () async {
        final response = await request.getTextResponseForUrl(url);
        return response.data ?? '';
      },
    );
    if (content == null || content.isEmpty || !mounted) {
      dialogs.showNotifier('下载失败或内容为空', level: MessageLevel.warning);
      return;
    }
    await _importConfContent(content);
  }

  Future<void> _importConfContent(String content) async {
    final conf = parseConf(content);
    if (conf.rules.isEmpty) {
      if (!mounted) return;
      dialogs.showNotifier('.conf 中没有找到规则', level: MessageLevel.warning);
      return;
    }
    final count = await ShadowrocketImport.importRules(ref, conf.rules);
    if (!mounted) return;
    dialogs.showNotifier('已导入 $count 条规则', level: MessageLevel.success);
  }

  void _showImportMenu() {
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: '导入规则',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.file_open),
              title: const Text('从 .conf 文件导入'),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportConf();
              },
            ),
            ListItem(
              leading: const Icon(Icons.link),
              title: const Text('从 URL 导入'),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportConfFromUrl();
              },
            ),
          ],
        ),
      ),
    );
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
          onPressed: _showImportMenu,
        ),
      ],
      body: const AddedRulesView(),
    );
  }
}
