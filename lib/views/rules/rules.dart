import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/views/rewrite/rewrite_menu.dart';
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
    final content = await globalState.safeRun(() async {
      final response = await request.getTextResponseForUrl(url);
      return response.data ?? '';
    });
    if (content == null || content.isEmpty || !mounted) {
      dialogs.showNotifier(
        appLocalizations.rulesDownloadFailed,
        level: MessageLevel.warning,
      );
      return;
    }
    await _importConfContent(content);
  }

  Future<void> _importConfContent(String content) async {
    final ConfData conf = parseConf(content);
    if (conf.rules.isEmpty) {
      if (!mounted) return;
      dialogs.showNotifier(
        currentAppLocalizations.noRulesInConf,
        level: MessageLevel.warning,
      );
      return;
    }
    final count = await ShadowrocketImport.importRules(ref, conf.rules);
    if (!mounted) return;
    dialogs.showNotifier(
      currentAppLocalizations.rulesImported(count),
      level: MessageLevel.success,
    );
  }

  void _showImportMenu() {
    final appLocalizations = context.appLocalizations;
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: appLocalizations.importRules,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.file_open),
              title: Text(appLocalizations.importRulesFromFile),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportConf();
              },
            ),
            ListItem(
              leading: const Icon(Icons.link),
              title: Text(appLocalizations.importFromUrl),
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
          icon: const Icon(Icons.tune_outlined),
          tooltip: appLocalizations.rewrite,
          onPressed: () => showRewriteMenu(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.file_open_outlined),
          tooltip: appLocalizations.importConfRules,
          onPressed: _showImportMenu,
        ),
      ],
      body: const AddedRulesView(),
    );
  }
}
