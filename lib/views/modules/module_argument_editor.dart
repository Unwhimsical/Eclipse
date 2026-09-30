import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/module.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Edit dialog for a module's `#!arguments=` user values.
/// Saving re-applies the module's rules with the new values.
class ModuleArgumentEditorDialog extends ConsumerStatefulWidget {
  final ModuleInfo info;
  final List<ModuleArgument> arguments;
  final Map<String, String> descriptions;

  const ModuleArgumentEditorDialog({
    super.key,
    required this.info,
    required this.arguments,
    this.descriptions = const {},
  });

  @override
  ConsumerState<ModuleArgumentEditorDialog> createState() =>
      _ModuleArgumentEditorDialogState();
}

class _ModuleArgumentEditorDialogState
    extends ConsumerState<ModuleArgumentEditorDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final arg in widget.arguments)
        arg.key: TextEditingController(
          text: widget.info.argumentValues[arg.key] ?? arg.defaultValue,
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final values = {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    await ShadowrocketImport.setModuleArgumentValues(ref, widget.info, values);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: '模块参数',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final arg in widget.arguments) ...[
              TextFormField(
                controller: _controllers[arg.key],
                decoration: InputDecoration(
                  labelText: arg.key,
                  hintText: arg.defaultValue,
                  helperText: widget.descriptions[arg.key],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
