import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Per-proxy "via" picker. Returns the picked proxy name, or '' for direct.
class _ViaPickerDialog extends StatelessWidget {
  final String proxyName;
  final List<String> candidates;
  final String? currentVia;

  const _ViaPickerDialog({
    required this.proxyName,
    required this.candidates,
    required this.currentVia,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: '代理通过',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem(
            leading: const Icon(Icons.link_off),
            title: const Text('直连'),
            subtitle: const Text('不经过其他节点'),
            trailing: currentVia == null
                ? const Icon(Icons.check, size: 20)
                : null,
            onTap: () => Navigator.of(context).pop(''),
          ),
          for (final name in candidates)
            ListItem(
              leading: const Icon(Icons.link),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: currentVia == name
                  ? const Icon(Icons.check, size: 20)
                  : null,
              onTap: () => Navigator.of(context).pop(name),
            ),
          const SizedBox(height: 8),
          Text(
            '选择后「$proxyName」的流量将先经过所选节点再出站',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Page editing the current profile's proxy chains ("dialer-proxy").
class ProxyChainEditorPage extends ConsumerStatefulWidget {
  final int profileId;

  const ProxyChainEditorPage({super.key, required this.profileId});

  @override
  ConsumerState<ProxyChainEditorPage> createState() =>
      _ProxyChainEditorPageState();
}

class _ProxyChainEditorPageState extends ConsumerState<ProxyChainEditorPage> {
  @override
  Widget build(BuildContext context) {
    final clashConfig = ref.watch(clashConfigProvider(widget.profileId));
    return CommonScaffold(
      title: '代理链',
      body: clashConfig.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const NullStatus(
          label: '读取节点列表失败',
          illustration: NullStatusIllustration.rules,
        ),
        data: (config) {
          if (config.proxies.isEmpty) {
            return const NullStatus(
              label: '当前配置没有节点',
              illustration: NullStatusIllustration.rules,
            );
          }
          return _ProxyChainList(
            profileId: widget.profileId,
            proxies: config.proxies,
          );
        },
      ),
    );
  }
}

class _ProxyChainList extends ConsumerStatefulWidget {
  final int profileId;
  final List<Proxy> proxies;

  const _ProxyChainList({required this.profileId, required this.proxies});

  @override
  ConsumerState<_ProxyChainList> createState() => _ProxyChainListState();
}

class _ProxyChainListState extends ConsumerState<_ProxyChainList> {
  late Map<String, String> _draft;
  late Set<String> _names;
  bool _cleaned = false;

  @override
  void initState() {
    super.initState();
    _names = {for (final proxy in widget.proxies) proxy.name};
    final stored =
        ref.read(profileProvider(widget.profileId))?.proxyChains ?? const {};
    _draft = sanitizeProxyChains(stored, _names);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cleanStaleOnce();
    });
  }

  Future<void> _persist(Map<String, String> chains) async {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          widget.profileId,
          (profile) => profile.copyWith(proxyChains: chains),
        );
    if (!mounted) return;
    if (ref.read(currentProfileIdProvider) == widget.profileId) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  /// Drops chain entries that reference proxies renamed or removed by a
  /// subscription update, so the stored map never holds dangling names.
  Future<void> _cleanStaleOnce() async {
    if (_cleaned) return;
    _cleaned = true;
    final stored =
        ref.read(profileProvider(widget.profileId))?.proxyChains ?? const {};
    final sameLength = stored.length == _draft.length;
    final sameEntries =
        sameLength &&
        stored.entries.every((entry) => _draft[entry.key] == entry.value);
    if (!sameEntries) {
      await _persist(_draft);
    }
  }

  String _chainLabel(String name) {
    final hops = resolveProxyChain(name, _draft, _names);
    if (hops.length < 2) return '直连出站';
    return '链路：${hops.join(' → ')} → 落地';
  }

  Future<void> _handlePickVia(String name) async {
    final candidates = _names.where((other) => other != name).toList()..sort();
    final picked = await dialogs.showCommonDialog<String>(
      child: _ViaPickerDialog(
        proxyName: name,
        candidates: candidates,
        currentVia: _draft[name],
      ),
    );
    if (picked == null || !mounted) return;
    final next = Map<String, String>.from(_draft);
    if (picked.isEmpty) {
      next.remove(name);
    } else {
      next[name] = picked;
    }
    if (hasProxyChainLoop(next)) {
      dialogs.showNotifier(
        '存在环路：${_loopLabel(next)}',
        level: MessageLevel.warning,
      );
      return;
    }
    setState(() => _draft = next);
    await _persist(next);
  }

  String _loopLabel(Map<String, String> chains) {
    for (final start in chains.keys) {
      final hops = resolveProxyChain(start, chains, _names);
      if (hops.length >= 2 && hops.first == hops.last) {
        return hops.join(' → ');
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final proxies = [...widget.proxies]
      ..sort((a, b) => a.name.compareTo(b.name));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: proxies.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final proxy = proxies[index];
        final via = _draft[proxy.name];
        return Card(
          child: ListItem(
            leading: const Icon(Icons.hub_outlined),
            title: Text(
              proxy.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${proxy.type} · ${_chainLabel(proxy.name)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: TextButton.icon(
              icon: Icon(via == null ? Icons.link_off : Icons.link, size: 18),
              label: Text(
                via ?? '直连',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => _handlePickVia(proxy.name),
            ),
          ),
        );
      },
    );
  }
}
