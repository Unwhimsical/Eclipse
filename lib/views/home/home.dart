import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/home/node_detail.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _RouteOption { config, proxy, direct, scene }

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonScaffold(
      title: context.appLocalizations.home,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HeroCard(),
          SizedBox(height: 16),
          _RouteModeCard(),
          SizedBox(height: 16),
          _ConnectivityCard(),
          SizedBox(height: 16),
          _NodesCard(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isStart = ref.watch(isStartProvider);
    final status = ref.watch(coreStatusProvider);
    final current = ref.watch(
      currentGroupsStateProvider.select(
        (state) => state.value.firstWhereOrNull(
          (group) => (group.now ?? '').isNotEmpty,
        ),
      ),
    );
    final traffics = ref.watch(trafficsProvider).list;
    final lastTraffic = traffics.isEmpty ? const Traffic() : traffics.last;
    final statusText = switch (status) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    final nodeName = current?.now ?? '';
    return CommonCard(
      radius: AppCorner.md,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PowerButton(
                  isStart: isStart,
                  connecting: status == CoreStatus.connecting,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          EclipseStatusDot(
                            color: isStart
                                ? EclipseSemantic.success
                                : colorScheme.onSurfaceVariant.opacity60,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              statusText,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isStart
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (nodeName.isNotEmpty)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${appLocalizations.currentNode}: $nodeName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _NodeDelayText(
                              proxyName: nodeName,
                              testUrl: current?.testUrl,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: ShapeDecoration(
                shape: AppShape.sm,
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SpeedItem(
                    icon: Icons.arrow_upward_rounded,
                    label: appLocalizations.upload,
                    value: '${lastTraffic.up.traffic.show}/s',
                  ),
                  _SpeedItem(
                    icon: Icons.arrow_downward_rounded,
                    label: appLocalizations.download,
                    value: '${lastTraffic.down.traffic.show}/s',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerButton extends ConsumerWidget {
  const _PowerButton({required this.isStart, required this.connecting});

  final bool isStart;
  final bool connecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: isStart
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
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
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.power_settings_new_rounded,
                    size: 34,
                    color: isStart
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SpeedItem extends StatelessWidget {
  const _SpeedItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NodeDelayText extends ConsumerWidget {
  const _NodeDelayText({required this.proxyName, required this.testUrl});

  final String proxyName;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: proxyName, testUrl: testUrl),
    );
    final pending = ref.watch(
      delayTestPendingProvider(proxyName: proxyName, testUrl: testUrl),
    );
    if (pending) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CommonCircleLoading(),
      );
    }
    if (delay == null) return const SizedBox.shrink();
    return Text(
      delay > 0 ? '$delay ms' : 'Timeout',
      style: context.textTheme.labelMedium?.copyWith(
        color: getDelayColor(delay),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RouteModeCard extends ConsumerWidget {
  const _RouteModeCard();

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
    return EclipseSection(
      title: appLocalizations.globalRoute,
      divided: false,
      children: [
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
              label: appLocalizations.routeScene,
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectivityCard extends ConsumerWidget {
  const _ConnectivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final detection = ref.watch(networkDetectionProvider);
    final ipInfo = detection.ipInfo;
    final isLoading = detection.isLoading;
    return EclipseSection(
      title: appLocalizations.connectivityTest,
      divided: false,
      children: [
        EclipseTile(
          icon: Icons.network_check_outlined,
          title: ipInfo?.ip ?? appLocalizations.connectivityTest,
          subtitle: ipInfo != null
              ? ipInfo.countryCode.toUpperCase()
              : appLocalizations.connectivityTest,
          trailing: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CommonCircleLoading(),
                )
              : IconButton(
                  tooltip: appLocalizations.connectivityTest,
                  icon: const Icon(Icons.play_arrow_rounded),
                  color: context.colorScheme.primary,
                  onPressed: () {
                    ref.read(networkDetectionProvider.notifier).startCheck();
                  },
                ),
        ),
      ],
    );
  }
}

class _NodesCard extends ConsumerStatefulWidget {
  const _NodesCard();

  @override
  ConsumerState<_NodesCard> createState() => _NodesCardState();
}

class _NodesCardState extends ConsumerState<_NodesCard> {
  final _expanded = <String>{};
  bool _testingAll = false;

  Future<void> _testAllDelays(List<Group> groups) async {
    if (_testingAll) return;
    setState(() => _testingAll = true);
    try {
      final seen = <String>{};
      final proxies = <Proxy>[];
      for (final group in groups) {
        for (final proxy in group.all) {
          if (seen.add(proxy.name)) proxies.add(proxy);
        }
      }
      await ref.read(proxiesActionProvider.notifier).delayTest(proxies);
    } finally {
      if (mounted) setState(() => _testingAll = false);
    }
  }

  Future<void> _testGroupDelays(Group group) {
    return ref
        .read(proxiesActionProvider.notifier)
        .delayTest(group.all, group.testUrl);
  }

  void _selectProxy(Group group, Proxy proxy) {
    final groupType = group.type;
    if (groupType.isComputedSelected || groupType == GroupType.Selector) {
      final currentProxyName = ref.read(proxyNameProvider(group.name));
      final nextProxyName = groupType.isComputedSelected
          ? (currentProxyName == proxy.name ? '' : proxy.name)
          : proxy.name;
      ref
          .read(proxiesActionProvider.notifier)
          .changeProxyDebounce(group.name, nextProxyName);
      return;
    }
    dialogs.showNotifier(
      currentAppLocalizations.notSelectedTip,
      level: MessageLevel.warning,
    );
  }

  void _openDetail(Group group, Proxy proxy) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NodeDetailPage(proxy: proxy, group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final groups = ref.watch(
      currentGroupsStateProvider.select((state) => state.value),
    );
    return EclipseSection(
      title: appLocalizations.nodes,
      subtitle: appLocalizations.delayTestDesc,
      trailing: _testingAll
          ? const SizedBox(width: 20, height: 20, child: CommonCircleLoading())
          : TextButton.icon(
              onPressed: groups.isEmpty ? null : () => _testAllDelays(groups),
              icon: const Icon(Icons.bolt_outlined, size: 18),
              label: Text(appLocalizations.delayTestAll),
            ),
      divided: false,
      children: [
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                appLocalizations.noNodesDesc,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final group in groups) _buildGroupBlock(group: group),
      ],
    );
  }

  Widget _buildGroupBlock({required Group group}) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final expanded = _expanded.contains(group.name);
    final selectedName = ref.watch(selectedProxyNameProvider(group.name)) ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: AppRadius.sm,
          onTap: () {
            setState(() {
              if (expanded) {
                _expanded.remove(group.name);
              } else {
                _expanded.add(group.name);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            selectedName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: appLocalizations.delayTest,
                  icon: const Icon(Icons.bolt_outlined, size: 20),
                  color: colorScheme.primary,
                  onPressed: () => _testGroupDelays(group),
                ),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          ...group.all.map(
            (proxy) => _NodeRow(
              group: group,
              proxy: proxy,
              selected: selectedName == proxy.name,
              onSelect: () => _selectProxy(group, proxy),
              onDetail: () => _openDetail(group, proxy),
            ),
          ),
      ],
    );
  }
}

class _NodeRow extends ConsumerWidget {
  const _NodeRow({
    required this.group,
    required this.proxy,
    required this.selected,
    required this.onSelect,
    required this.onDetail,
  });

  final Group group;
  final Proxy proxy;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    final pending = ref.watch(
      delayTestPendingProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    return InkWell(
      borderRadius: AppRadius.sm,
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 20,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.opacity60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                proxy.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: selected ? colorScheme.primary : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (pending)
              const SizedBox(
                width: 14,
                height: 14,
                child: CommonCircleLoading(),
              )
            else if (delay != null)
              Text(
                delay > 0 ? '$delay ms' : 'Timeout',
                style: textTheme.labelMedium?.copyWith(
                  color: getDelayColor(delay),
                ),
              ),
            IconButton(
              tooltip: context.appLocalizations.nodeDetail,
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              color: colorScheme.onSurfaceVariant,
              onPressed: onDetail,
            ),
          ],
        ),
      ),
    );
  }
}
