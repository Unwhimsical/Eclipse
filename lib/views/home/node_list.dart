import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/home/latency_pill.dart';
import 'package:fl_clash/views/home/node_detail.dart';
import 'package:fl_clash/views/proxies/selection.dart';
import 'package:fl_clash/views/proxies/sort_button.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeGroupList extends ConsumerWidget {
  const NodeGroupList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final groups = ref.watch(currentGroupsStateProvider).value;
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            appLocalizations.noNodesDesc,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appLocalizations.nodes,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const ProxySortButton(),
            IconButton(
              tooltip: appLocalizations.delayTestAll,
              onPressed: () {
                ref.read(proxiesActionProvider.notifier).delayTest([
                  for (final group in groups) ...group.all,
                ]);
              },
              icon: const Icon(Icons.speed_rounded),
            ),
          ],
        ),
        for (final group in groups) _GroupBlock(group: group),
      ],
    );
  }
}

class _GroupBlock extends ConsumerWidget {
  const _GroupBlock({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = resolvedSelectedName(ref, group);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 0, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.appLocalizations.delayTest,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  ref
                      .read(proxiesActionProvider.notifier)
                      .delayTest(group.all, group.testUrl);
                },
                icon: const Icon(Icons.bolt_outlined, size: 18),
              ),
            ],
          ),
        ),
        CommonCard(
          radius: AppCorner.xl,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < group.all.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 48,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                _NodeTile(
                  group: group,
                  proxy: group.all[i],
                  selected: selected == group.all[i].name,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeTile extends ConsumerWidget {
  const _NodeTile({
    required this.group,
    required this.proxy,
    required this.selected,
  });

  final Group group;
  final Proxy proxy;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    final pending = ref.watch(
      delayTestPendingProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    return InkWell(
      onTap: () => _select(ref),
      onLongPress: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NodeDetailPage(proxy: proxy, group: group),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                proxy.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colorScheme.primary : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            LatencyPill(
              delay: delay,
              pending: pending,
              onTap: () {
                ref
                    .read(proxiesActionProvider.notifier)
                    .proxyDelayTest(proxy, group.testUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _select(WidgetRef ref) {
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
}
