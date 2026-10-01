import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyShareView extends ConsumerStatefulWidget {
  const ProxyShareView({super.key});

  @override
  ConsumerState<ProxyShareView> createState() => _ProxyShareViewState();
}

class _ProxyShareViewState extends ConsumerState<ProxyShareView> {
  bool _loading = true;
  String? _lanIp;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lanIp = await getLocalIpAddress();
    if (!mounted) return;
    setState(() {
      _lanIp = lanIp;
      _loading = false;
    });
  }

  Future<void> _handleToggle(bool value) async {
    await FeatureFlags.setBool(FeatureFlags.proxySharing, value);
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(allowLan: value));
  }

  Future<void> _handleCopy(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    dialogs.showNotifier(
      context.appLocalizations.proxySharingCopied,
      level: MessageLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    final address = '${_lanIp ?? ''}:$mixedPort';
    return CommonScaffold(
      title: appLocalizations.proxySharing,
      isLoading: _loading,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.proxySharingSwitch),
                subtitle: Text(appLocalizations.proxySharingDesc),
                value: enabled,
                onChanged: _handleToggle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              if (enabled) ...[
                ListItem(
                  leading: const Icon(Icons.lan_outlined),
                  title: Text(appLocalizations.proxySharingAddress),
                  subtitle: Text(
                    address,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: appLocalizations.proxySharingCopy,
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () => _handleCopy(address),
                  ),
                ),
                ListItem(
                  leading: const Icon(Icons.smartphone_outlined),
                  title: Text(appLocalizations.proxySharingSteps),
                ),
                ListItem(
                  leading: const Icon(
                    Icons.security_outlined,
                    color: Colors.orange,
                  ),
                  title: Text(appLocalizations.proxySharingCertTip),
                ),
              ] else
                ListItem(
                  leading: const Icon(Icons.info_outline),
                  title: Text(appLocalizations.proxySharingOffTip),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
