import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UdpStunView extends ConsumerWidget {
  const UdpStunView({super.key});

  Future<void> _setUdp(WidgetRef ref, bool value) async {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(tun: state.tun.copyWith(udp: value)));
  }

  Future<void> _setDisableStun(WidgetRef ref, bool value) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    await ref
        .read(profilesActionProvider.notifier)
        .updateProfile(profile.copyWith(disableStun: value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final udpEnabled = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.udp),
    );
    final profile = ref.watch(currentProfileProvider);
    final stunDisabled = profile?.disableStun ?? false;
    return CommonScaffold(
      title: appLocalizations.udpForwardStun,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.udpForward),
                subtitle: Text(appLocalizations.udpForwardDesc),
                value: udpEnabled,
                onChanged: (v) => _setUdp(ref, v),
              ),
              ListItem.toggle(
                title: Text(appLocalizations.disableStun),
                subtitle: Text(appLocalizations.disableStunDesc),
                value: stunDisabled,
                onChanged: (v) => _setDisableStun(ref, v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
