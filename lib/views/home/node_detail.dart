import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeDetailPage extends ConsumerStatefulWidget {
  const NodeDetailPage({super.key, required this.proxy, required this.group});

  final Proxy proxy;
  final Group group;

  @override
  ConsumerState<NodeDetailPage> createState() => _NodeDetailPageState();
}

class _NodeDetailPageState extends ConsumerState<NodeDetailPage> {
  CoreController get _core => ref.read(coreHandlerProvider);

  List<TrackerInfo> _trackerInfos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final infos = await _core.getConnections();
      if (!mounted) return;
      setState(() {
        _trackerInfos = infos
            .where((info) => info.chains.contains(widget.proxy.name))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _handleSelect() {
    ref
        .read(proxiesActionProvider.notifier)
        .changeProxyDebounce(widget.group.name, widget.proxy.name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final proxy = widget.proxy;
    final group = widget.group;
    final uploadSpeed = _trackerInfos.fold<int>(
      0,
      (sum, info) => sum + (info.uploadSpeed ?? 0),
    );
    final downloadSpeed = _trackerInfos.fold<int>(
      0,
      (sum, info) => sum + (info.downloadSpeed ?? 0),
    );
    final uploadTotal = _trackerInfos.fold<int>(
      0,
      (sum, info) => sum + info.upload,
    );
    final downloadTotal = _trackerInfos.fold<int>(
      0,
      (sum, info) => sum + info.download,
    );
    final remoteAddresses = _trackerInfos
        .map((info) {
          final host = info.metadata.host;
          final target = host.isNotEmpty ? host : info.metadata.destinationIP;
          final port = info.metadata.destinationPort;
          return port.isNotEmpty ? '$target:$port' : target;
        })
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList();
    final localAddresses = _trackerInfos
        .map((info) {
          final ip = info.metadata.sourceIP;
          final port = info.metadata.sourcePort;
          if (ip.isEmpty) return '';
          return port.isNotEmpty ? '$ip:$port' : ip;
        })
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList();
    return BaseScaffold(
      title: appLocalizations.nodeDetail,
      actions: [
        IconButton(
          tooltip: appLocalizations.refresh,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _load,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EclipseSection(
            title: proxy.name,
            subtitle: group.name,
            children: [
              _InfoRow(label: appLocalizations.proxyType, value: proxy.type),
              _DelayRow(proxy: proxy, testUrl: group.testUrl),
              _InfoRow(
                label: appLocalizations.upload,
                value:
                    '${uploadTotal.traffic.show} (${uploadSpeed.traffic.show}/s)',
              ),
              _InfoRow(
                label: appLocalizations.download,
                value:
                    '${downloadTotal.traffic.show} (${downloadSpeed.traffic.show}/s)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          EclipseSection(
            title: appLocalizations.remoteAddress,
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CommonCircleLoading()),
                )
              else if (remoteAddresses.isEmpty)
                _EmptyHint(text: appLocalizations.noActiveConnections)
              else
                for (final address in remoteAddresses)
                  _InfoRow(label: '', value: address),
            ],
          ),
          const SizedBox(height: 16),
          EclipseSection(
            title: appLocalizations.localAddress,
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CommonCircleLoading()),
                )
              else if (localAddresses.isEmpty)
                _EmptyHint(text: appLocalizations.noActiveConnections)
              else
                for (final address in localAddresses)
                  _InfoRow(label: '', value: address),
            ],
          ),
          const SizedBox(height: 24),
          EclipsePrimaryButton(
            icon: Icons.check_circle_outline_rounded,
            label: appLocalizations.selectNode,
            onPressed: _handleSelect,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge,
              textAlign: label.isEmpty ? TextAlign.start : TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DelayRow extends ConsumerWidget {
  const _DelayRow({required this.proxy, required this.testUrl});

  final Proxy proxy;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: testUrl),
    );
    final pending = ref.watch(
      delayTestPendingProvider(proxyName: proxy.name, testUrl: testUrl),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              appLocalizations.delay,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: pending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CommonCircleLoading(),
                    )
                  : GestureDetector(
                      onTap: () {
                        ref
                            .read(proxiesActionProvider.notifier)
                            .proxyDelayTest(proxy, testUrl);
                      },
                      child: Text(
                        delay == null
                            ? appLocalizations.delayTest
                            : delay > 0
                            ? '$delay ms'
                            : 'Timeout',
                        style: textTheme.bodyLarge?.copyWith(
                          color: getDelayColor(delay) ?? colorScheme.primary,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
