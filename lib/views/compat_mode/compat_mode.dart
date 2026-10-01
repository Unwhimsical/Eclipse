import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompatModeView extends ConsumerWidget {
  const CompatModeView({super.key});

  Future<void> _handleToggle(WidgetRef ref, bool value) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    await ref
        .read(profilesActionProvider.notifier)
        .updateProfile(profile.copyWith(compatibilityMode: value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final enabled = profile?.compatibilityMode ?? false;
    return CommonScaffold(
      title: appLocalizations.compatMode,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.compatModeSwitch),
                subtitle: Text(appLocalizations.compatModeDesc),
                value: enabled,
                onChanged: (v) => _handleToggle(ref, v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            title: appLocalizations.compatModeEffects,
            items: [
              ListItem(
                leading: const Icon(Icons.swap_horiz_outlined),
                title: Text(appLocalizations.compatModeEffect1),
              ),
              ListItem(
                leading: const Icon(Icons.settings_ethernet_outlined),
                title: Text(appLocalizations.compatModeEffect2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem(
                leading: Icon(
                  Icons.phone_iphone_outlined,
                  color: context.colorScheme.tertiary,
                ),
                title: Text(appLocalizations.compatModeIosNote),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
