import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _mapLocalDataTypes = ['text', 'file', 'tiny-gif', 'base64'];

String _quoteToken(String value) {
  if (value.contains(' ') || value.contains('\t')) {
    return '"$value"';
  }
  return value;
}

/// Serialize a Map Local entry back to its `[Map Local]` line form.
/// Mirrors [parseMapLocalLine]; headers parsed from the original line are
/// carried through untouched.
String serializeMapLocalRule({
  required String pattern,
  required String dataType,
  required String data,
  required int statusCode,
  Map<String, String> headers = const {},
}) {
  return [
    _quoteToken(pattern),
    'data-type=$dataType',
    'data=${_quoteToken(data)}',
    'status-code=$statusCode',
    for (final entry in headers.entries)
      '${entry.key}=${_quoteToken(entry.value)}',
  ].join(' ');
}

/// Add/edit dialog for one Map Local entry. Returns the serialized line.
class MapLocalRuleDialog extends StatefulWidget {
  final String? line;

  const MapLocalRuleDialog({super.key, this.line});

  @override
  State<MapLocalRuleDialog> createState() => _MapLocalRuleDialogState();
}

class _MapLocalRuleDialogState extends State<MapLocalRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patternController;
  late final TextEditingController _dataController;
  late final TextEditingController _statusCodeController;
  late String _dataType;
  Map<String, String> _headers = const {};

  @override
  void initState() {
    super.initState();
    final parsed = widget.line == null ? null : parseMapLocalLine(widget.line!);
    _patternController = TextEditingController(text: parsed?.pattern ?? '');
    _dataController = TextEditingController(text: parsed?.data ?? '');
    _statusCodeController = TextEditingController(
      text: '${parsed?.statusCode ?? 200}',
    );
    _dataType = parsed?.dataType ?? _mapLocalDataTypes.first;
    _headers = parsed?.headers ?? const {};
  }

  @override
  void dispose() {
    _patternController.dispose();
    _dataController.dispose();
    _statusCodeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      serializeMapLocalRule(
        pattern: _patternController.text.trim(),
        dataType: _dataType,
        data: _dataController.text,
        statusCode: int.tryParse(_statusCodeController.text.trim()) ?? 200,
        headers: _headers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: widget.line == null ? '添加 Map Local' : '编辑 Map Local',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _patternController,
                decoration: const InputDecoration(labelText: 'URL 正则'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '不能为空' : null,
              ),
              const SizedBox(height: 12),
              DropdownMenu<String>(
                initialSelection: _dataType,
                label: const Text('数据类型'),
                dropdownMenuEntries: [
                  for (final type in _mapLocalDataTypes)
                    DropdownMenuEntry(value: type, label: type),
                ],
                onSelected: (value) {
                  if (value != null) setState(() => _dataType = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: '内容',
                  hintText: _dataType == 'file' ? '本地路径或远程 URL' : '响应内容',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusCodeController,
                decoration: const InputDecoration(labelText: '状态码'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    int.tryParse(value?.trim() ?? '') == null ? '请输入数字' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page editing the current profile's `[Map Local]` entries.
class MapLocalEditorPage extends ConsumerStatefulWidget {
  final int profileId;

  const MapLocalEditorPage({super.key, required this.profileId});

  @override
  ConsumerState<MapLocalEditorPage> createState() => _MapLocalEditorPageState();
}

class _MapLocalEditorPageState extends ConsumerState<MapLocalEditorPage> {
  Future<void> _persist(List<String> lines) async {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          widget.profileId,
          (profile) => profile.copyWith(mapLocal: lines),
        );
    if (ref.read(currentProfileIdProvider) == widget.profileId) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> _handleAddOrEdit([String? line]) async {
    final result = await dialogs.showCommonDialog<String>(
      child: MapLocalRuleDialog(line: line),
    );
    if (result == null || !mounted) return;
    final lines = [...?ref.read(profileProvider(widget.profileId))?.mapLocal];
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
      message: TextSpan(text: appLocalizations.deleteTip('Map Local')),
    );
    if (confirmed != true) return;
    final lines = [...?ref.read(profileProvider(widget.profileId))?.mapLocal]
      ..remove(line);
    await _persist(lines);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final lines = ref.watch(profileProvider(widget.profileId))?.mapLocal ?? [];
    return CommonScaffold(
      title: 'Map Local',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: appLocalizations.add,
          onPressed: () => _handleAddOrEdit(),
        ),
      ],
      body: NullStatusSwitcher(
        isEmpty: lines.isEmpty,
        nullStatus: const NullStatus(
          label: '暂无 Map Local 规则',
          illustration: NullStatusIllustration.rules,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final line = lines[index];
            final parsed = parseMapLocalLine(line);
            return Card(
              child: ListItem(
                title: Text(
                  parsed?.pattern ?? line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: parsed == null
                    ? const Text('无法解析')
                    : Text('${parsed.dataType} · ${parsed.statusCode}'),
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
