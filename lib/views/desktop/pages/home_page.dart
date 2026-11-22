import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/home/node_list.dart';
import 'package:fl_clash/views/home/route_mode_bar.dart';
import 'package:fl_clash/views/proxies/selection.dart';
import 'package:fl_clash/views/proxies/sort_button.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/desktop/pages/simple_page.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop home: status column on the left, the node list filling the rest.
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
          actions: [
            const ProxySortButton(),
            const _DelayTestAction(),
            const SimpleModeToggleButton(),
            const DesktopRunSwitch(),
          ],
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SizedBox(width: 340, child: _SideColumn()),
                Expanded(child: _NodePane()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DelayTestAction extends ConsumerWidget {
  const _DelayTestAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return OutlinedButton.icon(
      onPressed: () {
        final groups = ref.read(currentGroupsStateProvider).value;
        if (groups.isEmpty) return;
        final active = firstResolvedNode(ref, groups, listen: false);
        final proxies = active == null
            ? [for (final group in groups) ...group.all]
            : active.group.all;
        ref.read(proxiesActionProvider.notifier).delayTest(proxies);
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
    // When not started, always show disconnected regardless of stale coreStatus.
    final effectiveStatus = isStart ? status : CoreStatus.disconnected;
    final statusText = switch (effectiveStatus) {
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
          Text(
            appLocalizations.routeMode,
            style: theme.textTheme.labelSmall?.copyWith(color: text2),
          ),
          const RouteModeBar(),
        ],
      ),
    );
  }

  String _currentNodeName(WidgetRef ref) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    return firstResolvedNode(ref, groups)?.name ?? '';
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
    final engaged = isStart || connecting;
    return SizedBox(
      width: 84,
      height: 84,
      child: Material(
        color: engaged ? accent : Colors.white.withValues(alpha: 0.06),
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
                ? const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.power_settings_new_rounded,
                    size: 36,
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

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_RunCard(), _TrafficCard()],
    );
  }
}

class _NodePane extends StatelessWidget {
  const _NodePane();

  @override
  Widget build(BuildContext context) {
    return const DesktopCard(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: NodeGroupList(),
    );
  }
}

class _TrafficCard extends ConsumerWidget {
  const _TrafficCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final samples = ref.watch(trafficsProvider.select((s) => s.list));
    if (samples.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DesktopCard(
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
      ),
    );
  }
}
