import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TailscaleView extends ConsumerWidget {
  const TailscaleView({super.key});

  Future<void> _update(
    WidgetRef ref,
    AppSettingProps Function(AppSettingProps state) update,
  ) async {
    ref.read(appSettingProvider.notifier).update(update);
    ref.read(setupActionProvider.notifier).applyProfileDebounce();
  }

  Future<void> _editAuthKey(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final result = await dialogs.showCommonDialog<String>(
      child: CommonDialog(
        title: appLocalizations.tailscaleAuthKey,
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
          obscureText: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ),
    );
    controller.dispose();
    if (result == null || !context.mounted) return;
    await _update(ref, (state) => state.copyWith(tailscaleAuthKey: result));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final setting = ref.watch(appSettingProvider);
    return CommonScaffold(
      title: appLocalizations.tailscale,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.tailscale),
                subtitle: Text(appLocalizations.tailscaleDesc),
                value: setting.tailscaleEnabled,
                onChanged: (v) => _update(
                  ref,
                  (state) => state.copyWith(tailscaleEnabled: v),
                ),
              ),
              ListItem(
                title: Text(appLocalizations.tailscaleAuthKey),
                subtitle: Text(appLocalizations.tailscaleAuthKeyDesc),
                onTap: () => _editAuthKey(
                  context,
                  ref,
                  appLocalizations,
                  setting.tailscaleAuthKey,
                ),
              ),
              ListItem.input(
                title: Text(appLocalizations.tailscaleControlUrl),
                dialogTitle: appLocalizations.tailscaleControlUrl,
                value: setting.tailscaleControlUrl,
                onChanged: (v) {
                  if (v == null) return;
                  _update(
                    ref,
                    (state) => state.copyWith(tailscaleControlUrl: v.trim()),
                  );
                },
              ),
              ListItem.input(
                title: Text(appLocalizations.tailscaleHostname),
                dialogTitle: appLocalizations.tailscaleHostname,
                value: setting.tailscaleHostname,
                onChanged: (v) {
                  if (v == null) return;
                  _update(
                    ref,
                    (state) => state.copyWith(tailscaleHostname: v.trim()),
                  );
                },
              ),
              ListItem.input(
                title: Text(appLocalizations.tailscaleExitNode),
                subtitle: Text(appLocalizations.tailscaleExitNodeDesc),
                dialogTitle: appLocalizations.tailscaleExitNode,
                value: setting.tailscaleExitNode,
                onChanged: (v) {
                  if (v == null) return;
                  _update(
                    ref,
                    (state) => state.copyWith(tailscaleExitNode: v.trim()),
                  );
                },
              ),
              ListItem.toggle(
                title: Text(appLocalizations.tailscaleAcceptRoutes),
                subtitle: Text(appLocalizations.tailscaleAcceptRoutesDesc),
                value: setting.tailscaleAcceptRoutes,
                onChanged: (v) => _update(
                  ref,
                  (state) => state.copyWith(tailscaleAcceptRoutes: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.tailscaleStatusHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
