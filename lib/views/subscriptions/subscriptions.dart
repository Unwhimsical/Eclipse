import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Node subscriptions: URL subscriptions plus Shadowrocket share-link and
/// `.conf` imports, in the style of a Surge/Shadowrocket subscription list.
class SubscriptionsView extends ConsumerStatefulWidget {
  const SubscriptionsView({super.key});

  @override
  ConsumerState<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends ConsumerState<SubscriptionsView> {
  Future<void> _handleAddFromURL() async {
    final url = await dialogs.showCommonDialog<String>(
      child: const _URLInputDialog(),
    );
    if (url == null || url.isEmpty || !mounted) return;
    await ref.read(profilesActionProvider.notifier).addProfileFormURL(url);
  }

  Future<void> _handleImportLinks() async {
    final text = await dialogs.showCommonDialog<String>(
      child: const _LinksInputDialog(),
    );
    if (text == null || text.isEmpty || !mounted) return;
    final label = await ShadowrocketImport.importShareLinks(ref, text: text);
    if (!mounted) return;
    dialogs.showNotifier(
      label == null ? '未识别到有效节点' : '已导入：$label',
      level: label == null ? MessageLevel.warning : MessageLevel.success,
    );
  }

  Future<void> _handleImportConf() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null || !mounted) return;
    final bytes = await platformFile.readBytes();
    final content = String.fromCharCodes(bytes);
    final label = await ShadowrocketImport.importConf(
      ref,
      content: content,
      fileName: platformFile.name,
    );
    if (!mounted) return;
    dialogs.showNotifier(
      label == null ? '未识别到有效内容' : '已导入：$label',
      level: label == null ? MessageLevel.warning : MessageLevel.success,
    );
  }

  void _showAddMenu() {
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: currentAppLocalizations.addSubscription,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.link),
              title: Text(currentAppLocalizations.importFromURL),
              onTap: () {
                Navigator.of(context).pop();
                _handleAddFromURL();
              },
            ),
            ListItem(
              leading: const Icon(Icons.paste),
              title: const Text('导入分享链接'),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportLinks();
              },
            ),
            ListItem(
              leading: const Icon(Icons.file_open),
              title: const Text('导入 .conf 文件'),
              onTap: () {
                Navigator.of(context).pop();
                _handleImportConf();
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
    final state = ref.watch(profilesStateProvider);
    final subscriptions = state.profiles
        .where((p) => p.url.isNotEmpty)
        .toList();
    return CommonScaffold(
      title: appLocalizations.subscriptions,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
      body: NullStatusSwitcher(
        isEmpty: subscriptions.isEmpty,
        nullStatus: NullStatus(
          label: '暂无订阅，点击 + 添加',
          illustration: NullStatusIllustration.profile,
        ),
        child: ListView.builder(
          itemCount: subscriptions.length,
          itemBuilder: (_, index) {
            final profile = subscriptions[index];
            return _SubscriptionTile(profile: profile);
          },
        ),
      ),
    );
  }
}

class _SubscriptionTile extends ConsumerWidget {
  final Profile profile;

  const _SubscriptionTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent =
        ref.watch(profilesStateProvider).currentProfileId == profile.id;
    return ListItem(
      leading: const Icon(Icons.cloud_download),
      title: Text(
        profile.label.isEmpty ? profile.url : profile.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: profile.subscriptionInfo != null
          ? Text(_formatTraffic(profile.subscriptionInfo!))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrent) const Icon(Icons.check),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新订阅',
            onPressed: () {
              ref.read(profilesActionProvider.notifier).updateProfile(profile);
            },
          ),
        ],
      ),
      onTap: () {
        ref.read(currentProfileIdProvider.notifier).value = profile.id;
      },
    );
  }

  String _formatTraffic(SubscriptionInfo info) {
    String format(int bytes) {
      if (bytes <= 0) return '0';
      const units = ['B', 'KB', 'MB', 'GB', 'TB'];
      var value = bytes.toDouble();
      var unit = 0;
      while (value >= 1024 && unit < units.length - 1) {
        value /= 1024;
        unit++;
      }
      return '${value.toStringAsFixed(1)} ${units[unit]}';
    }

    return '${format(info.upload + info.download)} / ${format(info.total)}';
  }
}

class _URLInputDialog extends StatefulWidget {
  const _URLInputDialog();

  @override
  State<_URLInputDialog> createState() => _URLInputDialogState();
}

class _URLInputDialogState extends State<_URLInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.value.text.trim()),
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: appLocalizations.url),
          onSubmitted: (_) =>
              Navigator.of(context).pop(_controller.value.text.trim()),
        ),
      ),
    );
  }
}

class _LinksInputDialog extends StatefulWidget {
  const _LinksInputDialog();

  @override
  State<_LinksInputDialog> createState() => _LinksInputDialogState();
}

class _LinksInputDialogState extends State<_LinksInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: '导入分享链接',
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.value.text.trim()),
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: _controller,
          maxLines: 8,
          minLines: 4,
          decoration: const InputDecoration(
            labelText: 'ss:// / vmess:// / trojan:// …',
            hintText: '每行一个链接，也支持 base64 订阅内容',
          ),
        ),
      ),
    );
  }
}
