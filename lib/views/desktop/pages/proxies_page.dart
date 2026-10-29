import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop node list page: groups in order, tap a node to select it.
/// Reached from the sidebar and from the home page "switch node" button.
class DesktopProxiesView extends ConsumerWidget {
  const DesktopProxiesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final groups = ref.watch(currentGroupsStateProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.proxies,
          actions: [
            OutlinedButton.icon(
              onPressed: groups.isEmpty
                  ? null
                  : () {
                      ref
                          .read(proxiesActionProvider.notifier)
                          .delayTest(groups.expand((g) => g.all).toList());
                    },
              icon: const Icon(Icons.speed_rounded, size: 18),
              label: Text(appLocalizations.delayTest),
            ),
          ],
        ),
        Expanded(
          child: groups.isEmpty
              ? Center(child: Text(appLocalizations.noNodes))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _GroupSection(group: groups[i]),
                ),
        ),
      ],
    );
  }
}

class _GroupSection extends ConsumerWidget {
  const _GroupSection({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: tokens?.groupTitleStyle.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: context.appLocalizations.delayTest,
                iconSize: 18,
                onPressed: () {
                  ref.read(proxiesActionProvider.notifier).delayTest(group.all);
                },
                icon: const Icon(Icons.speed_rounded),
              ),
            ],
          ),
        ),
        Column(
          spacing: 8,
          children: [
            for (final proxy in group.all)
              _ProxyRow(group: group, proxy: proxy),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ProxyRow extends ConsumerWidget {
  const _ProxyRow({required this.group, required this.proxy});

  final Group group;
  final Proxy proxy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final text1 = tokens?.text1 ?? theme.colorScheme.onSurface;
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    final selected = group.now == proxy.name;
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    final delayText = delay == null
        ? ''
        : (delay > 0 ? '$delay ms' : 'Timeout');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref
            .read(proxiesActionProvider.notifier)
            .changeProxy(groupName: group.name, proxyName: proxy.name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
            side: BorderSide(
              color: selected ? accent : Colors.white.withValues(alpha: 0.06),
              width: selected ? 1.5 : 1,
            ),
          ),
          color: selected
              ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
              : Colors.transparent,
        ),
        child: Row(
          spacing: 12,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 20,
              color: selected ? accent : text3,
            ),
            Expanded(
              child: Text(
                proxy.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? accent : text1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              proxy.type,
              style: theme.textTheme.labelSmall?.copyWith(color: text3),
            ),
            if (delayText.isNotEmpty)
              Text(
                delayText,
                style: theme.textTheme.labelSmall?.copyWith(color: text3),
              ),
          ],
        ),
      ),
    );
  }
}
