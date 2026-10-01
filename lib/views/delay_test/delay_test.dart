import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DelayTestView extends ConsumerStatefulWidget {
  const DelayTestView({super.key});

  @override
  ConsumerState<DelayTestView> createState() => _DelayTestViewState();
}

class _DelayTestViewState extends ConsumerState<DelayTestView> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ref.read(appSettingProvider.select((state) => state.delayTestUrl)),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _setMethod(DelayTestMethod method) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(delayTestMethod: method));
  }

  void _saveUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(delayTestUrl: url));
    dialogs.showNotifier(
      context.appLocalizations.save,
      level: MessageLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final method = ref.watch(
      appSettingProvider.select((state) => state.delayTestMethod),
    );
    final methods = [
      (
        DelayTestMethod.tcp,
        appLocalizations.delayTestMethodTcp,
        appLocalizations.delayTestMethodTcpDesc,
      ),
      (
        DelayTestMethod.icmp,
        appLocalizations.delayTestMethodIcmp,
        appLocalizations.delayTestMethodIcmpDesc,
      ),
      (
        DelayTestMethod.connect,
        appLocalizations.delayTestMethodConnect,
        appLocalizations.delayTestMethodConnectDesc,
      ),
    ];
    return CommonScaffold(
      title: appLocalizations.delayTest,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            title: appLocalizations.delayTestMethod,
            items: [
              RadioGroup<DelayTestMethod>(
                groupValue: method,
                onChanged: (v) {
                  if (v != null) _setMethod(v);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (value, label, desc) in methods)
                      ListItem.radio(
                        value: value,
                        title: Text(label),
                        subtitle: Text(desc),
                        onTap: () => _setMethod(value),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            title: appLocalizations.delayTestUrl,
            items: [
              ListItem(
                title: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.delayTestUrlHint,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (_) => _saveUrl(),
                ),
                trailing: TextButton(
                  onPressed: _saveUrl,
                  child: Text(appLocalizations.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
