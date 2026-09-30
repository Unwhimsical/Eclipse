import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _bodyRewriteTypes = [
  'http-request',
  'http-response',
  'http-request-jq',
  'http-response-jq',
];

bool _isJqType(String type) => type.endsWith('-jq');

/// Serialize a Body Rewrite entry back to its `[Body Rewrite]` line form.
/// Mirrors [parseBodyRewriteLine].
String serializeBodyRewriteRule({
  required String type,
  required String pattern,
  String regex = '',
  String replacement = '',
  String jq = '',
}) {
  if (_isJqType(type)) {
    return '$type $pattern $jq';
  }
  return '$type $pattern $regex $replacement';
}

/// Add/edit dialog for one Body Rewrite entry. Returns the serialized line.
class BodyRewriteRuleDialog extends StatefulWidget {
  final String? line;

  const BodyRewriteRuleDialog({super.key, this.line});

  @override
  State<BodyRewriteRuleDialog> createState() => _BodyRewriteRuleDialogState();
}

class _BodyRewriteRuleDialogState extends State<BodyRewriteRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patternController;
  late final TextEditingController _regexController;
  late final TextEditingController _replacementController;
  late final TextEditingController _jqController;
  late String _type;

  @override
  void initState() {
    super.initState();
    final parsed = widget.line == null
        ? null
        : parseBodyRewriteLine(widget.line!);
    _patternController = TextEditingController(text: parsed?.pattern ?? '');
    _regexController = TextEditingController(text: parsed?.regex ?? '');
    _replacementController = TextEditingController(
      text: parsed?.replacement ?? '',
    );
    _jqController = TextEditingController(text: parsed?.jq ?? '');
    _type = parsed?.type ?? _bodyRewriteTypes.first;
  }

  @override
  void dispose() {
    _patternController.dispose();
    _regexController.dispose();
    _replacementController.dispose();
    _jqController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      serializeBodyRewriteRule(
        type: _type,
        pattern: _patternController.text.trim(),
        regex: _regexController.text,
        replacement: _replacementController.text,
        jq: _jqController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isJq = _isJqType(_type);
    return CommonDialog(
      title: widget.line == null ? '添加 Body Rewrite' : '编辑 Body Rewrite',
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
              DropdownMenu<String>(
                initialSelection: _type,
                label: const Text('类型'),
                dropdownMenuEntries: [
                  for (final type in _bodyRewriteTypes)
                    DropdownMenuEntry(value: type, label: type),
                ],
                onSelected: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patternController,
                decoration: const InputDecoration(labelText: 'URL 正则'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '不能为空' : null,
              ),
              const SizedBox(height: 12),
              if (isJq)
                TextFormField(
                  controller: _jqController,
                  decoration: const InputDecoration(
                    labelText: 'jq 表达式',
                    hintText: 'del(.data.ad)',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '不能为空' : null,
                )
              else ...[
                TextFormField(
                  controller: _regexController,
                  decoration: const InputDecoration(labelText: '正则'),
                  validator: (value) =>
                      value == null || value.isEmpty ? '不能为空' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _replacementController,
                  decoration: const InputDecoration(labelText: '替换为'),
                  validator: (value) =>
                      value == null || value.isEmpty ? '不能为空' : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Page editing the current profile's `[Body Rewrite]` entries.
class BodyRewriteEditorPage extends ConsumerStatefulWidget {
  final int profileId;

  const BodyRewriteEditorPage({super.key, required this.profileId});

  @override
  ConsumerState<BodyRewriteEditorPage> createState() =>
      _BodyRewriteEditorPageState();
}

class _BodyRewriteEditorPageState extends ConsumerState<BodyRewriteEditorPage> {
  Future<void> _persist(List<String> lines) async {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          widget.profileId,
          (profile) => profile.copyWith(bodyRewrites: lines),
        );
    if (ref.read(currentProfileIdProvider) == widget.profileId) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> _handleAddOrEdit([String? line]) async {
    final result = await dialogs.showCommonDialog<String>(
      child: BodyRewriteRuleDialog(line: line),
    );
    if (result == null || !mounted) return;
    final lines = [
      ...?ref.read(profileProvider(widget.profileId))?.bodyRewrites,
    ];
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
      message: TextSpan(text: appLocalizations.deleteTip('Body Rewrite')),
    );
    if (confirmed != true) return;
    final lines = [
      ...?ref.read(profileProvider(widget.profileId))?.bodyRewrites,
    ]..remove(line);
    await _persist(lines);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final lines =
        ref.watch(profileProvider(widget.profileId))?.bodyRewrites ?? [];
    return CommonScaffold(
      title: 'Body Rewrite',
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
          label: '暂无 Body Rewrite 规则',
          illustration: NullStatusIllustration.rules,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final line = lines[index];
            final parsed = parseBodyRewriteLine(line);
            return Card(
              child: ListItem(
                title: Text(
                  parsed?.pattern ?? line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: parsed == null
                    ? const Text('无法解析')
                    : Text(
                        _isJqType(parsed.type)
                            ? '${parsed.type} · ${parsed.jq}'
                            : parsed.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
