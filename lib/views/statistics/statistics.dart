import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TrafficCategory { proxy, direct, reject, other }

TrafficCategory categorizeConnection(TrackerInfo info) {
  if (info.rule.toUpperCase().contains('REJECT')) {
    return TrafficCategory.reject;
  }
  if (info.chains.isNotEmpty) {
    return TrafficCategory.proxy;
  }
  if (info.rule.isNotEmpty) {
    return TrafficCategory.direct;
  }
  return TrafficCategory.other;
}

class CategoryTraffic {
  int upload = 0;
  int download = 0;

  int get total => upload + download;
}

Map<TrafficCategory, CategoryTraffic> aggregateTraffic(
  List<TrackerInfo> infos,
) {
  final result = {
    for (final category in TrafficCategory.values) category: CategoryTraffic(),
  };
  for (final info in infos) {
    final bucket = result[categorizeConnection(info)]!;
    bucket.upload += info.upload;
    bucket.download += info.download;
  }
  return result;
}

class StatisticsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const StatisticsView({super.key, @visibleForTesting this.connectionsReader});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView>
    with WidgetsBindingObserver, ActivePollingMixin<StatisticsView> {
  List<TrackerInfo> _infos = [];

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  Future<void> poll(PollGuard isCurrent) async {
    List<TrackerInfo>? infos;
    try {
      infos = widget.connectionsReader != null
          ? await widget.connectionsReader!()
          : await ref.read(coreHandlerProvider).getConnections();
    } catch (_) {
      return;
    }
    if (!isCurrent() || !mounted) return;
    setState(() => _infos = infos ?? const []);
  }

  String _trafficText(int bytes) {
    return Traffic(up: 0, down: bytes).desc;
  }

  Widget _buildCategoryRow(
    AppLocalizations appLocalizations,
    String label,
    IconData icon,
    CategoryTraffic traffic,
  ) {
    return ListItem(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        _trafficText(traffic.total),
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildConnectionItem(
    AppLocalizations appLocalizations,
    TrackerInfo info,
  ) {
    final policy = info.chains.isEmpty ? '—' : info.chains.last;
    final ruleText = info.rulePayload.isEmpty
        ? info.rule
        : '${info.rule} ${info.rulePayload}';
    return ListItem(
      title: Text(info.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${appLocalizations.statConnRule}: $ruleText\n'
        '${appLocalizations.statConnPolicy}: $policy · '
        '${appLocalizations.statConnProtocol}: ${info.metadata.network.toUpperCase()}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _trafficText(info.upload + info.download),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final aggregated = aggregateTraffic(_infos);
    final sorted = List.of(
      _infos,
    )..sort((a, b) => (b.upload + b.download).compareTo(a.upload + a.download));
    return CommonScaffold(
      title: appLocalizations.statistics,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            title: appLocalizations.statByPolicy,
            items: [
              _buildCategoryRow(
                appLocalizations,
                appLocalizations.statProxy,
                Icons.vpn_lock_outlined,
                aggregated[TrafficCategory.proxy]!,
              ),
              _buildCategoryRow(
                appLocalizations,
                appLocalizations.statDirect,
                Icons.lan_outlined,
                aggregated[TrafficCategory.direct]!,
              ),
              _buildCategoryRow(
                appLocalizations,
                appLocalizations.statReject,
                Icons.block_outlined,
                aggregated[TrafficCategory.reject]!,
              ),
              _buildCategoryRow(
                appLocalizations,
                appLocalizations.statOther,
                Icons.help_outline,
                aggregated[TrafficCategory.other]!,
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.statNetTypeNote),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            generateSectionV2(
              title: appLocalizations.statConnections,
              items: [
                ListItem(
                  leading: const Icon(Icons.inbox_outlined),
                  title: Text(appLocalizations.statNoConnections),
                ),
              ],
            )
          else
            generateSectionV2(
              title: '${appLocalizations.statConnections} (${sorted.length})',
              items: [
                for (final info in sorted)
                  _buildConnectionItem(appLocalizations, info),
              ],
            ),
        ],
      ),
    );
  }
}
