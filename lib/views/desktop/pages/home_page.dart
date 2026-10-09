import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/desktop/pages/config_page.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _RouteOption { config, proxy, direct, scene }

/// §2 desktop home: 320px run-status card left, traffic chart + current
/// node card right, [delay test][run switch] in the header.
class DesktopHomeView extends ConsumerWidget {
  const DesktopHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.dashboard,
          actions: [_DelayTestAction(), const DesktopRunSwitch()],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const SizedBox(width: 320, child: _RunCard()),
                Expanded(
                  child: Column(
                    spacing: 16,
                    children: [const _TrafficCard(), const _CurrentNodeCard()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DelayTestAction extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return OutlinedButton.icon(
      onPressed: () {
        final groups = ref.read(currentGroupsStateProvider).value;
        final group = groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty);
        if (group == null) return;
        ref.read(proxiesActionProvider.notifier).delayTest(group.all);
      },
      icon: const Icon(Icons.speed_rounded, size: 18),
      label: Text(appLocalizations.delayTest),
    );
  }
}

class _RunCard extends ConsumerWidget {
  const _RunCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final isStart = ref.watch(isStartProvider);
    final status = ref.watch(coreStatusProvider);
    final traffics = ref.watch(trafficsProvider).list;
    final lastTraffic = traffics.isEmpty ? const Traffic() : traffics.last;
    final statusText = switch (status) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    final text2 = tokens?.text2 ?? theme.colorScheme.onSurfaceVariant;
    return DesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 16,
            children: [
              _PowerButton(
                isStart: isStart,
                connecting: status == CoreStatus.connecting,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      appLocalizations.runStatus,
                      style: tokens?.groupTitleStyle.copyWith(fontSize: 13),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isStart
                                ? (tokens?.success ?? theme.colorScheme.primary)
                                : (tokens?.text3 ??
                                      theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            statusText,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  tokens?.text1 ?? theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _RunCardRow(
            icon: Icons.hub_outlined,
            label: appLocalizations.currentNode,
            value: _currentNodeName(ref),
            text2: text2,
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _RunCardRow(
                  icon: Icons.arrow_upward_rounded,
                  label: appLocalizations.upload,
                  value: '${lastTraffic.up.traffic.show}/s',
                  text2: text2,
                ),
              ),
              Expanded(
                child: _RunCardRow(
                  icon: Icons.arrow_downward_rounded,
                  label: appLocalizations.download,
                  value: '${lastTraffic.down.traffic.show}/s',
                  text2: text2,
                ),
              ),
            ],
          ),
          const _RouteModeSegment(),
        ],
      ),
    );
  }

  String _currentNodeName(WidgetRef ref) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    return groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty)?.now ?? '';
  }
}

class _RunCardRow extends StatelessWidget {
  const _RunCardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.text2,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color text2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(icon, size: 14, color: text2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: text2),
            ),
          ],
        ),
        Text(
          value.isEmpty ? '—' : value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: DesktopThemeTokens.kpiFontFeatures,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _PowerButton extends ConsumerWidget {
  const _PowerButton({required this.isStart, required this.connecting});

  final bool isStart;
  final bool connecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: isStart ? accent : Colors.white.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: connecting
              ? null
              : () {
                  ref.read(commonActionProvider.notifier).toggleRunning();
                },
          child: Center(
            child: connecting
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.power_settings_new_rounded,
                    size: 34,
                    color: isStart
                        ? Colors.white
                        : (tokens?.text2 ?? theme.colorScheme.onSurfaceVariant),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RouteModeSegment extends ConsumerWidget {
  const _RouteModeSegment();

  void _handleChange(_RouteOption option, WidgetRef ref) {
    final sceneEnabled = ref.read(sceneModeEnabledProvider);
    if (option == _RouteOption.scene) {
      if (!sceneEnabled) {
        ref.read(sceneModeEnabledProvider.notifier).update((_) => true);
      }
      return;
    }
    if (sceneEnabled) {
      ref.read(sceneModeEnabledProvider.notifier).update((_) => false);
    }
    ref.read(setupActionProvider.notifier).changeMode(switch (option) {
      _RouteOption.config => Mode.rule,
      _RouteOption.proxy => Mode.global,
      _RouteOption.direct => Mode.direct,
      _RouteOption.scene => Mode.rule,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
    final sceneEnabled = ref.watch(sceneModeEnabledProvider);
    final groupValue = sceneEnabled
        ? _RouteOption.scene
        : switch (mode) {
            Mode.global => _RouteOption.proxy,
            Mode.direct => _RouteOption.direct,
            _ => _RouteOption.config,
          };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          appLocalizations.routeMode,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color:
                Theme.of(context).extension<DesktopThemeTokens>()?.text2 ??
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        EclipseSegmented<_RouteOption>(
          groupValue: groupValue,
          onChanged: (option) => _handleChange(option, ref),
          options: [
            EclipseSegmentOption(
              value: _RouteOption.config,
              label: appLocalizations.routeConfig,
            ),
            EclipseSegmentOption(
              value: _RouteOption.proxy,
              label: appLocalizations.routeProxy,
            ),
            EclipseSegmentOption(
              value: _RouteOption.direct,
              label: appLocalizations.routeDirect,
            ),
            EclipseSegmentOption(
              value: _RouteOption.scene,
              label: appLocalizations.sceneMode,
            ),
          ],
        ),
      ],
    );
  }
}

class _TrafficCard extends ConsumerWidget {
  const _TrafficCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final samples = ref.watch(trafficsProvider.select((s) => s.list));
    return DesktopCard(
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
          TrafficChart(samples: samples),
        ],
      ),
    );
  }
}

class _CurrentNodeCard extends ConsumerWidget {
  const _CurrentNodeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final groups = ref.watch(currentGroupsStateProvider).value;
    final group = groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty);
    final nodeName = group?.now ?? '';
    final proxy = group?.all.firstWhereOrNull((p) => p.name == nodeName);
    return DesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(appLocalizations.currentNode, style: tokens?.groupTitleStyle),
          if (nodeName.isEmpty)
            Text(
              appLocalizations.noNodes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        nodeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${group?.name ?? ''} · ${_delayText(ref, nodeName, group?.testUrl)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              tokens?.text2 ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ref.read(desktopConfigTabProvider.notifier).value = 0;
                    ref
                        .read(currentPageLabelProvider.notifier)
                        .toPage(PageLabel.config);
                  },
                  child: Text(appLocalizations.switchNode),
                ),
              ],
            ),
          if (proxy != null)
            Text(
              proxy.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _delayText(WidgetRef ref, String proxyName, String? testUrl) {
    final delay = ref.watch(
      delayProvider(proxyName: proxyName, testUrl: testUrl),
    );
    if (delay == null) return '';
    return delay > 0 ? '$delay ms' : 'Timeout';
  }
}
