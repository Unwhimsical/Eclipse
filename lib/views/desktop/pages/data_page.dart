import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _DataSegment { connections, requests, logs }

/// §2 desktop data page: 64px KPI strip, 180px trend chart, segmented
/// table (connections | requests | logs) with resizable/sortable columns.
/// Header: [export][clear].
class DesktopDataView extends ConsumerStatefulWidget {
  const DesktopDataView({super.key});

  @override
  ConsumerState<DesktopDataView> createState() => _DesktopDataViewState();
}

class _DesktopDataViewState extends ConsumerState<DesktopDataView>
    with WidgetsBindingObserver {
  _DataSegment _segment = _DataSegment.connections;
  final _baselines = KpiBaselines();
  List<TrackerInfo> _connections = [];
  Timer? _pollTimer;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_baselines.ensureLoaded());
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshConnections();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _refreshConnections();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshConnections();
  }

  Future<void> _refreshConnections() async {
    try {
      final infos = await _core.getConnections();
      if (!mounted) return;
      final sorted = List<TrackerInfo>.of(infos)
        ..sort((a, b) {
          final traffic = (b.upload + b.download).compareTo(
            a.upload + a.download,
          );
          if (traffic != 0) return traffic;
          return b.start.compareTo(a.start);
        });
      setState(() => _connections = sorted);
    } catch (_) {
      // Core unreachable: keep the last snapshot.
    }
  }

  Future<void> _handleExport() async {
    final ok = await ref.read(logsProvider.notifier).exportLogs();
    if (!mounted) return;
    context.showNotifier(
      ok
          ? context.appLocalizations.exportSuccess
          : context.appLocalizations.exportFailed,
      level: ok ? MessageLevel.success : MessageLevel.error,
    );
  }

  Future<void> _handleClear() async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.clearAction,
      message: appLocalizations.clearConfirmMessage,
      confirmLabel: appLocalizations.clearAction,
      danger: true,
    );
    if (!confirmed) return;
    ref.read(trafficsProvider.notifier).clear();
    ref.read(logsProvider.notifier).clear();
    ref.read(requestsProvider.notifier).clear();
    await _refreshConnections();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final totalTraffic = ref.watch(totalTrafficProvider);
    unawaited(_baselines.recordTraffic(totalTraffic.up, totalTraffic.down));
    final requests = ref.watch(requestsProvider).list;
    final logs = ref.watch(logsProvider).list;
    final ruleHits = _connections
        .where((c) => c.rule.isNotEmpty && c.rule != 'MATCH')
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.data,
          actions: [
            OutlinedButton.icon(
              onPressed: _handleExport,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(appLocalizations.exportAction),
            ),
            OutlinedButton.icon(
              onPressed: _handleClear,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(appLocalizations.clearAction),
            ),
            const DesktopRunSwitch(),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              spacing: 16,
              children: [
                DesktopCard(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: KpiStrip(
                    kpis: [
                      KpiData(
                        label: appLocalizations.totalUpload,
                        value: totalTraffic.up.traffic.show,
                        trend: _baselines.upTrend(totalTraffic.up),
                      ),
                      KpiData(
                        label: appLocalizations.totalDownload,
                        value: totalTraffic.down.traffic.show,
                        trend: _baselines.downTrend(totalTraffic.down),
                      ),
                      KpiData(
                        label: appLocalizations.activeConnections,
                        value: '${_connections.length}',
                        trend: _baselines.connectionTrend(_connections.length),
                      ),
                      KpiData(
                        label: appLocalizations.ruleHits,
                        value: '$ruleHits',
                      ),
                    ],
                  ),
                ),
                DesktopCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        appLocalizations.trafficTrend,
                        style: Theme.of(
                          context,
                        ).extension<DesktopThemeTokens>()?.groupTitleStyle,
                      ),
                      TrafficChart(
                        samples: ref.watch(
                          trafficsProvider.select((s) => s.list),
                        ),
                        height: 180,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DesktopCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: EclipseSegmented<_DataSegment>(
                                  groupValue: _segment,
                                  onChanged: (s) =>
                                      setState(() => _segment = s),
                                  options: [
                                    EclipseSegmentOption(
                                      value: _DataSegment.connections,
                                      label: appLocalizations.connections,
                                    ),
                                    EclipseSegmentOption(
                                      value: _DataSegment.requests,
                                      label: appLocalizations.requests,
                                    ),
                                    EclipseSegmentOption(
                                      value: _DataSegment.logs,
                                      label: appLocalizations.logs,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                            child: switch (_segment) {
                              _DataSegment.connections => _ConnectionsTable(
                                connections: _connections,
                                now: _now,
                                onClose: _handleCloseConnection,
                              ),
                              _DataSegment.requests => _RequestsTable(
                                requests: requests,
                              ),
                              _DataSegment.logs => _LogsTable(logs: logs),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCloseConnection(String id) async {
    try {
      await _core.closeConnection(id);
    } catch (_) {
      // Best-effort; the next poll refreshes the list anyway.
    }
    await _refreshConnections();
  }
}

String _destinationOf(TrackerInfo info) {
  final host = info.metadata.host;
  if (host.isNotEmpty) return host;
  return info.metadata.destinationIP;
}

Widget _monoCell(BuildContext context, String text, {Color? color}) {
  final theme = Theme.of(context);
  final tokens = theme.extension<DesktopThemeTokens>();
  return Text(
    text,
    style: theme.textTheme.bodySmall?.copyWith(
      fontFamily: DesktopThemeTokens.monoFontFamily,
      fontFamilyFallback: DesktopThemeTokens.monoFontFamilyFallback,
      color: color ?? tokens?.text1 ?? theme.colorScheme.onSurface,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _numCell(BuildContext context, String text) {
  final theme = Theme.of(context);
  final tokens = theme.extension<DesktopThemeTokens>();
  return Text(
    text,
    style: theme.textTheme.bodySmall?.copyWith(
      fontFeatures: DesktopThemeTokens.kpiFontFeatures,
      color: tokens?.text2 ?? theme.colorScheme.onSurfaceVariant,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.end,
  );
}

class _ConnectionsTable extends StatelessWidget {
  const _ConnectionsTable({
    required this.connections,
    required this.now,
    required this.onClose,
  });

  final List<TrackerInfo> connections;
  final DateTime now;
  final Future<void> Function(String id) onClose;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DesktopTable<TrackerInfo>(
      rowHeight: 40,
      rows: connections,
      emptyLabel: appLocalizations.noConnections,
      columns: [
        DesktopColumn(
          title: appLocalizations.destination,
          width: 260,
          cell: (c) => _monoCell(context, _destinationOf(c)),
          sortKey: _destinationOf,
        ),
        DesktopColumn(
          title: appLocalizations.rule,
          width: 140,
          cell: (c) => _monoCell(context, c.rule),
          sortKey: (c) => c.rule,
        ),
        DesktopColumn(
          title: '↑',
          width: 90,
          align: TextAlign.end,
          cell: (c) => _numCell(context, c.upload.traffic.show),
          sortKey: (c) => c.upload,
        ),
        DesktopColumn(
          title: '↓',
          width: 90,
          align: TextAlign.end,
          cell: (c) => _numCell(context, c.download.traffic.show),
          sortKey: (c) => c.download,
        ),
        DesktopColumn(
          title: appLocalizations.speed,
          width: 110,
          align: TextAlign.end,
          cell: (c) => _numCell(
            context,
            '${((c.uploadSpeed ?? 0) + (c.downloadSpeed ?? 0)).traffic.show}/s',
          ),
          sortKey: (c) => (c.uploadSpeed ?? 0) + (c.downloadSpeed ?? 0),
        ),
        DesktopColumn(
          title: appLocalizations.duration,
          width: 90,
          align: TextAlign.end,
          cell: (c) =>
              _numCell(context, _formatDuration(now.difference(c.start))),
          sortKey: (c) => c.start.millisecondsSinceEpoch,
        ),
        DesktopColumn(
          title: appLocalizations.tableAction,
          width: 80,
          sortable: false,
          resizable: false,
          cell: (c) => IconButton(
            tooltip: appLocalizations.closeConnection,
            iconSize: 16,
            onPressed: () => onClose(c.id),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}

class _RequestsTable extends StatelessWidget {
  const _RequestsTable({required this.requests});

  final List<TrackerInfo> requests;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DesktopTable<TrackerInfo>(
      rowHeight: 40,
      rows: requests,
      emptyLabel: appLocalizations.noRequests,
      columns: [
        DesktopColumn(
          title: appLocalizations.time,
          width: 90,
          cell: (c) => _numCell(context, _formatTime(c.start)),
          sortKey: (c) => c.start.millisecondsSinceEpoch,
        ),
        DesktopColumn(
          title: appLocalizations.destination,
          width: 300,
          cell: (c) => _monoCell(context, _destinationOf(c)),
          sortKey: _destinationOf,
        ),
        DesktopColumn(
          title: appLocalizations.rule,
          width: 140,
          cell: (c) => _monoCell(context, c.rule),
          sortKey: (c) => c.rule,
        ),
        DesktopColumn(
          title: '↑',
          width: 90,
          align: TextAlign.end,
          cell: (c) => _numCell(context, c.upload.traffic.show),
          sortKey: (c) => c.upload,
        ),
        DesktopColumn(
          title: '↓',
          width: 90,
          align: TextAlign.end,
          cell: (c) => _numCell(context, c.download.traffic.show),
          sortKey: (c) => c.download,
        ),
      ],
    );
  }
}

String _formatTime(DateTime t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  final s = t.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class _LogsTable extends ConsumerWidget {
  const _LogsTable({required this.logs});

  final List<Log> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    Color levelColor(LogLevel level) {
      return switch (level) {
        LogLevel.error => tokens?.danger ?? theme.colorScheme.error,
        LogLevel.warning => tokens?.warning ?? theme.colorScheme.primary,
        _ => tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
      };
    }

    return DesktopTable<Log>(
      rowHeight: 40,
      rows: logs,
      emptyLabel: appLocalizations.noLogs,
      rowMenuBuilder: (log) => [
        DesktopMenuItem(
          label: appLocalizations.copyAction,
          icon: Icons.content_copy_rounded,
          value: () async {
            await Clipboard.setData(ClipboardData(text: log.payload));
          },
        ),
        DesktopMenuItem(
          label: appLocalizations.clearLogs,
          icon: Icons.delete_sweep_outlined,
          danger: true,
          value: () => _confirmClearLogs(context, ref),
        ),
      ],
      columns: [
        DesktopColumn(
          title: appLocalizations.time,
          width: 90,
          cell: (l) =>
              _numCell(context, _formatTime(_parseLogTime(l.dateTime))),
          sortKey: (l) => l.dateTime,
        ),
        DesktopColumn(
          title: appLocalizations.level,
          width: 90,
          cell: (l) => Text(
            l.logLevel.name.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: levelColor(l.logLevel),
              fontWeight: FontWeight.w700,
            ),
          ),
          sortKey: (l) => l.logLevel.index,
        ),
        DesktopColumn(
          title: appLocalizations.logs,
          width: 520,
          cell: (l) => _monoCell(context, l.payload),
          sortable: false,
        ),
      ],
    );
  }

  Future<void> _confirmClearLogs(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.clearLogs,
      message: appLocalizations.clearConfirmMessage,
      confirmLabel: appLocalizations.clearAction,
      danger: true,
    );
    if (!confirmed) return;
    ref.read(logsProvider.notifier).clear();
  }
}

DateTime _parseLogTime(String raw) {
  return DateTime.tryParse(raw) ?? DateTime.now();
}
