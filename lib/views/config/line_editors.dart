import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _LinesOf = List<String> Function(Profile profile);
typedef _CopyLines = Profile Function(Profile profile, List<String> lines);

class _LineListEditorPage extends ConsumerStatefulWidget {
  final int profileId;
  final String title;
  final _LinesOf linesOf;
  final _CopyLines copyLines;

  const _LineListEditorPage({
    required this.profileId,
    required this.title,
    required this.linesOf,
    required this.copyLines,
  });

  @override
  ConsumerState<_LineListEditorPage> createState() =>
      _LineListEditorPageState();
}

class _LineListEditorPageState extends ConsumerState<_LineListEditorPage> {
  Future<void> _persist(List<String> lines) async {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          widget.profileId,
          (profile) => widget.copyLines(profile, lines),
        );
    if (ref.read(currentProfileIdProvider) == widget.profileId) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> _handleAddOrEdit([String? line]) async {
    final appLocalizations = context.appLocalizations;
    final controller = TextEditingController(text: line ?? '');
    final result = await dialogs.showCommonDialog<String>(
      child: CommonDialog(
        title: line == null ? appLocalizations.add : appLocalizations.edit,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(appLocalizations.save),
          ),
        ],
        child: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || !mounted) return;
    final profile = ref.read(profileProvider(widget.profileId));
    final lines = <String>[if (profile != null) ...widget.linesOf(profile)];
    if (line == null) {
      lines.add(result);
    } else {
      final index = lines.indexOf(line);
      if (index != -1) lines[index] = result;
    }
    await _persist(lines);
  }

  Future<void> _handleDelete(String line) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteTip(widget.title)),
    );
    if (confirmed != true) return;
    final profile = ref.read(profileProvider(widget.profileId));
    final lines = <String>[if (profile != null) ...widget.linesOf(profile)]
      ..remove(line);
    await _persist(lines);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(profileProvider(widget.profileId));
    final lines = <String>[if (profile != null) ...widget.linesOf(profile)];
    return CommonScaffold(
      title: widget.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: appLocalizations.add,
          onPressed: () => _handleAddOrEdit(),
        ),
      ],
      body: NullStatusSwitcher(
        isEmpty: lines.isEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.nullTip(widget.title),
          illustration: NullStatusIllustration.rules,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final line = lines[index];
            return Card(
              child: ListItem(
                title: Text(line, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: appLocalizations.edit,
                      onPressed: () => _handleAddOrEdit(line),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: appLocalizations.delete,
                      onPressed: () => _handleDelete(line),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UrlRewriteEditorPage extends StatelessWidget {
  final int profileId;

  const UrlRewriteEditorPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return _LineListEditorPage(
      profileId: profileId,
      title: context.appLocalizations.urlRewrite,
      linesOf: (p) => p.urlRewrites,
      copyLines: (p, lines) => p.copyWith(urlRewrites: lines),
    );
  }
}

class HeaderRewriteEditorPage extends StatelessWidget {
  final int profileId;

  const HeaderRewriteEditorPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return _LineListEditorPage(
      profileId: profileId,
      title: context.appLocalizations.headerRewrite,
      linesOf: (p) => p.headerRewrites,
      copyLines: (p, lines) => p.copyWith(headerRewrites: lines),
    );
  }
}

class HostEditorPage extends ConsumerWidget {
  final int profileId;

  const HostEditorPage({super.key, required this.profileId});

  Future<void> _persist(WidgetRef ref, Map<String, String> value) async {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(profileId, (p) => p.copyWith(hosts: value));
    if (ref.read(currentProfileIdProvider) == profileId) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hosts = ref.watch(profileProvider(profileId))?.hosts ?? {};
    return CommonScaffold(
      title: appLocalizations.hostSection,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.open(
                leading: const Icon(Icons.view_list_outlined),
                title: Text(appLocalizations.hostSection),
                subtitle: Text(appLocalizations.hostsDesc),
                blur: false,
                widget: MapInputPage(
                  title: appLocalizations.hostSection,
                  map: hosts,
                  keyMaxLength: TextInputLimits.domain,
                  valueMaxLength: TextInputLimits.hostValue,
                  titleBuilder: (item) => Text(item.key),
                  subtitleBuilder: (item) => Text(item.value),
                ),
                onChanged: (value) {
                  if (value is Map<String, String>) _persist(ref, value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
