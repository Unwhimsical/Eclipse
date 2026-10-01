import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool isFrontProxyCandidate(Proxy proxy) {
  final type = proxy.type.toLowerCase();
  return type == 'http' || type == 'socks5';
}

class FrontProxyView extends ConsumerStatefulWidget {
  final ClashConfig? testConfig;

  const FrontProxyView({super.key, @visibleForTesting this.testConfig});

  @override
  ConsumerState<FrontProxyView> createState() => _FrontProxyViewState();
}

class _FrontProxyViewState extends ConsumerState<FrontProxyView> {
  Future<void> _handleSelect(String? id) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    await ref
        .read(profilesActionProvider.notifier)
        .updateProfile(profile.copyWith(frontProxyId: id));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final selectedId = profile?.frontProxyId;
    final configAsync = widget.testConfig != null
        ? AsyncValue.data(widget.testConfig!)
        : (profile == null
              ? const AsyncValue.loading()
              : ref.watch(clashConfigProvider(profile.id)));
    return CommonScaffold(
      title: appLocalizations.frontProxy,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.frontProxyDesc),
                subtitle: Text(appLocalizations.frontProxyOnlyHttpSocks),
              ),
            ],
          ),
          const SizedBox(height: 16),
          configAsync.when(
            data: (config) => _buildList(appLocalizations, config, selectedId),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => ListItem(
              leading: const Icon(Icons.error_outline),
              title: Text(appLocalizations.frontProxyEmpty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    AppLocalizations appLocalizations,
    ClashConfig config,
    String? selectedId,
  ) {
    final candidates = config.proxies.where(isFrontProxyCandidate).toList();
    final items = <Widget>[
      ListItem<String?>.radio(
        value: null,
        onTap: () => _handleSelect(null),
        title: Text(appLocalizations.frontProxyNone),
      ),
      for (final proxy in candidates)
        ListItem<String?>.radio(
          value: proxy.name,
          onTap: () => _handleSelect(proxy.name),
          title: Text(proxy.name),
          subtitle: Text(proxy.type.toUpperCase()),
        ),
    ];
    if (candidates.isEmpty) {
      items.add(
        ListItem(
          leading: const Icon(Icons.inbox_outlined),
          title: Text(appLocalizations.frontProxyEmpty),
        ),
      );
    }
    return RadioGroup<String?>(
      groupValue: selectedId,
      onChanged: _handleSelect,
      child: generateSectionV2(items: items),
    );
  }
}
