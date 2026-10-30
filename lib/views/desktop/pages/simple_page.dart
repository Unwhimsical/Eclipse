import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Switches the desktop UI morphology and lands on the dashboard, so
/// entering and leaving simple mode never strands the user on a page
/// simple mode hides.
void setDesktopSimpleMode(WidgetRef ref, bool value) {
  ref
      .read(appSettingProvider.notifier)
      .update((state) => state.copyWith(simpleMode: value));
  ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.dashboard);
}

/// Header quick toggle, kept in sync with the settings-page switch through
/// the same [AppSettingProps.simpleMode] value.
class SimpleModeToggleButton extends ConsumerWidget {
  const SimpleModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final simpleMode = ref.watch(
      appSettingProvider.select((state) => state.simpleMode),
    );
    return OutlinedButton.icon(
      onPressed: () => setDesktopSimpleMode(ref, !simpleMode),
      icon: Icon(
        simpleMode ? Icons.dashboard_customize_outlined : Icons.tune_rounded,
        size: 18,
      ),
      label: Text(
        simpleMode ? appLocalizations.fullMode : appLocalizations.simpleMode,
      ),
    );
  }
}

/// Scope picker for automatic lowest-delay selection, shared by the
/// simplified view and the settings page. Null means every node on the
/// dashboard; a group name narrows the range to that group's nodes.
class AutoSelectScopeDropdown extends ConsumerWidget {
  const AutoSelectScopeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final groups = ref.watch(currentGroupsStateProvider).value;
    final scope = ref.watch(
      appSettingProvider.select((state) => state.autoSelectGroup),
    );
    final names = groups.map((group) => group.name).toSet().toList();
    final value = scope != null && names.contains(scope) ? scope : null;
    return DropdownButton<String?>(
      value: value,
      underline: const SizedBox.shrink(),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(appLocalizations.autoSelectGroupAll),
        ),
        for (final name in names)
          DropdownMenuItem(value: name, child: Text(name)),
      ],
      onChanged: (next) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoSelectGroup: next));
      },
    );
  }
}

enum _SimpleRouteOption { config, proxy, direct }

/// Simplified desktop dashboard: power switch, current node, route
/// segment and traffic numbers only. Config, rules, modules, data and
/// settings pages are hidden while this view is shown; module and proxy
/// state itself is untouched. The full-mode button at the bottom restores
/// the six-page navigation.
class DesktopSimpleView extends ConsumerWidget {
  const DesktopSimpleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.dashboard,
          actions: const [SimpleModeToggleButton(), DesktopRunSwitch()],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: const Column(
                  spacing: 16,
                  children: [
                    _SimpleRunCard(),
                    _SimpleRouteCard(),
                    _SimpleTrafficCard(),
                    _SimpleAutoSelectCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const SizedBox(
                width: double.infinity,
                child: _FullModeButton(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullModeButton extends ConsumerWidget {
  const _FullModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return FilledButton(
      onPressed: () => setDesktopSimpleMode(ref, false),
      child: Text(appLocalizations.fullMode),
    );
  }
}

class _SimpleRunCard extends ConsumerWidget {
  const _SimpleRunCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final isStart = ref.watch(isStartProvider);
    final status = ref.watch(coreStatusProvider);
    final groups = ref.watch(currentGroupsStateProvider).value;
    final group = groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty);
    final nodeName = group?.now ?? '';
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
              _SimplePowerButton(
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
                    Text(
                      statusText,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens?.text1 ?? theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      nodeName.isEmpty
                          ? appLocalizations.noNodes
                          : '$nodeName · ${_delayText(ref, nodeName, group?.testUrl)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: group == null
                    ? null
                    : () {
                        ref
                            .read(proxiesActionProvider.notifier)
                            .delayTest(group.all);
                      },
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: Text(appLocalizations.delayTest),
              ),
              if (group != null)
                Expanded(
                  child: DropdownButton<String>(
                    value: nodeName,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final proxy in group.all)
                        DropdownMenuItem(
                          value: proxy.name,
                          child: Text(
                            proxy.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (next) {
                      if (next == null) return;
                      ref
                          .read(proxiesActionProvider.notifier)
                          .changeProxy(groupName: group.name, proxyName: next);
                    },
                  ),
                ),
            ],
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

class _SimplePowerButton extends ConsumerWidget {
  const _SimplePowerButton({required this.isStart, required this.connecting});

  final bool isStart;
  final bool connecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return SizedBox(
      width: 96,
      height: 96,
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
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.power_settings_new_rounded,
                    size: 44,
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

class _SimpleRouteCard extends ConsumerWidget {
  const _SimpleRouteCard();

  void _handleChange(_SimpleRouteOption option, WidgetRef ref) {
    if (ref.read(sceneModeEnabledProvider)) {
      ref.read(sceneModeEnabledProvider.notifier).update((_) => false);
    }
    ref.read(setupActionProvider.notifier).changeMode(switch (option) {
      _SimpleRouteOption.config => Mode.rule,
      _SimpleRouteOption.proxy => Mode.global,
      _SimpleRouteOption.direct => Mode.direct,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
    final groupValue = switch (mode) {
      Mode.global => _SimpleRouteOption.proxy,
      Mode.direct => _SimpleRouteOption.direct,
      _ => _SimpleRouteOption.config,
    };
    return DesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            appLocalizations.routeMode,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens?.text2 ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          EclipseSegmented<_SimpleRouteOption>(
            groupValue: groupValue,
            onChanged: (option) => _handleChange(option, ref),
            options: [
              EclipseSegmentOption(
                value: _SimpleRouteOption.config,
                label: appLocalizations.routeConfig,
              ),
              EclipseSegmentOption(
                value: _SimpleRouteOption.proxy,
                label: appLocalizations.routeProxy,
              ),
              EclipseSegmentOption(
                value: _SimpleRouteOption.direct,
                label: appLocalizations.routeDirect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimpleTrafficCard extends ConsumerWidget {
  const _SimpleTrafficCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final traffics = ref.watch(trafficsProvider).list;
    final lastTraffic = traffics.isEmpty ? const Traffic() : traffics.last;
    final total = ref.watch(totalTrafficProvider);
    final text2 = tokens?.text2 ?? theme.colorScheme.onSurfaceVariant;
    return DesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _TrafficNumber(
                  icon: Icons.arrow_downward_rounded,
                  label: appLocalizations.download,
                  value: '${lastTraffic.down.traffic.show}/s',
                  text2: text2,
                ),
              ),
              Expanded(
                child: _TrafficNumber(
                  icon: Icons.arrow_upward_rounded,
                  label: appLocalizations.upload,
                  value: '${lastTraffic.up.traffic.show}/s',
                  text2: text2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                appLocalizations.todayTraffic,
                style: theme.textTheme.labelSmall?.copyWith(color: text2),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: _TrafficNumber(
                      icon: Icons.arrow_downward_rounded,
                      label: appLocalizations.download,
                      value: total.down.traffic.show,
                      text2: text2,
                    ),
                  ),
                  Expanded(
                    child: _TrafficNumber(
                      icon: Icons.arrow_upward_rounded,
                      label: appLocalizations.upload,
                      value: total.up.traffic.show,
                      text2: text2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrafficNumber extends StatelessWidget {
  const _TrafficNumber({
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
          value,
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

class _SimpleAutoSelectCard extends ConsumerWidget {
  const _SimpleAutoSelectCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.autoSelectLowestDelay),
    );
    return DesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      appLocalizations.autoSelectLowestDelay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      appLocalizations.autoSelectLowestDelayDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (value) {
                  ref
                      .read(appSettingProvider.notifier)
                      .update(
                        (state) => state.copyWith(autoSelectLowestDelay: value),
                      );
                },
              ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Text(
                  appLocalizations.autoSelectGroup,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const AutoSelectScopeDropdown(),
            ],
          ),
        ],
      ),
    );
  }
}
