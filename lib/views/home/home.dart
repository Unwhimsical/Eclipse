import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/components/traffic_chart.dart';
import 'package:fl_clash/views/home/latency_pill.dart';
import 'package:fl_clash/views/home/node_list.dart';
import 'package:fl_clash/views/home/route_mode_bar.dart';
import 'package:fl_clash/views/proxies/selection.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samples = ref.watch(trafficsProvider.select((state) => state.list));
    return CommonScaffold(
      title: context.appLocalizations.home,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _ConnectHeader(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: RouteModeBar(),
              ),
              if (samples.length >= 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TrafficChart(samples: samples, height: 88),
                ),
              const Expanded(child: NodeGroupList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectHeader extends ConsumerWidget {
  const _ConnectHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final isStart = ref.watch(isStartProvider);
    final status = ref.watch(coreStatusProvider);
    final effective = isStart ? status : CoreStatus.disconnected;
    final groups = ref.watch(currentGroupsStateProvider).value;
    final active = firstResolvedNode(ref, groups);
    final nodeName = active?.name ?? '';
    final delay = nodeName.isEmpty
        ? null
        : ref.watch(
            delayProvider(proxyName: nodeName, testUrl: active?.group.testUrl),
          );
    final pending =
        nodeName.isNotEmpty &&
        ref.watch(
          delayTestPendingProvider(
            proxyName: nodeName,
            testUrl: active?.group.testUrl,
          ),
        );
    final traffics = ref.watch(trafficsProvider).list;
    final last = traffics.isEmpty ? const Traffic() : traffics.last;
    final statusText = switch (effective) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    final live = effective != CoreStatus.disconnected;
    return Column(
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: Material(
            color: live
                ? colorScheme.primary
                : colorScheme.surfaceContainerHigh,
            shape: const CircleBorder(),
            elevation: live ? 2 : 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: effective == CoreStatus.connecting
                  ? null
                  : () {
                      ref.read(commonActionProvider.notifier).toggleRunning();
                    },
              child: Center(
                child: effective == CoreStatus.connecting
                    ? SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.power_settings_new_rounded,
                        size: 52,
                        color: live
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EclipseStatusDot(
              color: switch (effective) {
                CoreStatus.connected => EclipseSemantic.success,
                CoreStatus.connecting => EclipseSemantic.warning,
                CoreStatus.disconnected =>
                  colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              },
            ),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (nodeName.isEmpty)
          Text(
            appLocalizations.noNodes,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  nodeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              LatencyPill(
                delay: delay,
                pending: pending,
                onTap: () {
                  final proxy = active?.group.all
                      .where((item) => item.name == nodeName)
                      .firstOrNull;
                  if (proxy == null) return;
                  ref
                      .read(proxiesActionProvider.notifier)
                      .proxyDelayTest(proxy, active?.group.testUrl);
                },
              ),
            ],
          ),
        const SizedBox(height: 10),
        Text(
          '↑ ${last.up.traffic.show}/s    ↓ ${last.down.traffic.show}/s',
          style: context.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
