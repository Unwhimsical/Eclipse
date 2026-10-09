import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/proxy_link.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/desktop/value_holder.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

/// Detail tab index for the desktop config page; the home page sets it to
/// the nodes tab before navigating here.
final desktopConfigTabProvider = valueHolder(0);

/// §2 desktop config page: 320px profile list (drag-sort) left, detail with
/// compact 节点|规则 tabs right. Header: [search][import][add].
class DesktopConfigView extends ConsumerStatefulWidget {
  const DesktopConfigView({super.key});

  @override
  ConsumerState<DesktopConfigView> createState() => _DesktopConfigViewState();
}

class _DesktopConfigViewState extends ConsumerState<DesktopConfigView> {
  bool _searchOpen = false;
  String _query = '';
  int? _selectedId;
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final currentId = ref.watch(currentProfileIdProvider);
    _selectedId ??= currentId ?? profiles.firstOrNull?.id;
    if (_selectedId != null && profiles.every((p) => p.id != _selectedId)) {
      _selectedId = currentId ?? profiles.firstOrNull?.id;
    }
    final selected = profiles.firstWhereOrNull((p) => p.id == _selectedId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopPageHeader(
          title: appLocalizations.config,
          actions: [
            if (_searchOpen)
              SizedBox(
                width: 220,
                child: TextField(
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: appLocalizations.search,
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                  onSubmitted: (_) {},
                ),
              ),
            IconButton(
              tooltip: appLocalizations.search,
              onPressed: () {
                setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) _query = '';
                });
                if (_searchOpen) _searchFocus.requestFocus();
              },
              icon: const Icon(Icons.search_rounded),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(profilesActionProvider.notifier)
                    .addProfileFormFile(widgetRef: ref);
              },
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(appLocalizations.import),
            ),
            FilledButton.icon(
              onPressed: () => _handleAddProfile(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(appLocalizations.addProfile),
            ),
            const DesktopRunSwitch(),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: _ProfileListPanel(
                    profiles: profiles,
                    currentId: currentId,
                    selectedId: _selectedId,
                    query: _query,
                    onSelect: (id) => setState(() => _selectedId = id),
                    onReorder: (oldIndex, newIndex) {
                      final filtered = _filtered(profiles, _query);
                      final item = filtered[oldIndex];
                      final next = List<Profile>.from(profiles);
                      next.remove(item);
                      final target = filtered[newIndex];
                      final at = next.indexOf(target);
                      next.insert(newIndex > oldIndex ? at + 1 : at, item);
                      ref.read(profilesActionProvider.notifier).reorder(next);
                    },
                    onAdd: _handleAddProfile,
                  ),
                ),
                Expanded(
                  child: selected == null
                      ? _EmptyDetail(
                          hasProfiles: profiles.isNotEmpty,
                          query: _query,
                          onClearSearch: () => setState(() => _query = ''),
                          onAdd: _handleAddProfile,
                        )
                      : _ProfileDetail(
                          key: ValueKey(selected.id),
                          profile: selected,
                          isCurrent: selected.id == currentId,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Profile> _filtered(List<Profile> profiles, String query) {
    if (query.isEmpty) return profiles;
    final q = query.toLowerCase();
    return profiles
        .where((p) => p.realLabel.toLowerCase().contains(q))
        .toList();
  }

  void _handleAddProfile() {
    final context = globalState.navigatorKey.currentContext;
    if (context == null) return;
    unawaited(dialogs.showCommonDialog(child: const _AddProfileDialog()));
  }
}

class _AddProfileDialog extends ConsumerStatefulWidget {
  const _AddProfileDialog();

  @override
  ConsumerState<_AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends ConsumerState<_AddProfileDialog> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.addProfile,
      child: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: appLocalizations.profileUrlHint,
                labelText: appLocalizations.subscriptionLink,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final url = _urlController.text.trim();
                    Navigator.of(context).pop();
                    if (url.isEmpty) {
                      await ref
                          .read(profilesActionProvider.notifier)
                          .addProfileFormFile(widgetRef: ref);
                    } else {
                      await ref
                          .read(profilesActionProvider.notifier)
                          .addProfileFormURL(url, widgetRef: ref);
                    }
                  },
                  child: Text(appLocalizations.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileListPanel extends StatelessWidget {
  const _ProfileListPanel({
    required this.profiles,
    required this.currentId,
    required this.selectedId,
    required this.query,
    required this.onSelect,
    required this.onReorder,
    required this.onAdd,
  });

  final List<Profile> profiles;
  final int? currentId;
  final int? selectedId;
  final String query;
  final ValueChanged<int> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final q = query.toLowerCase();
    final filtered = q.isEmpty
        ? profiles
        : profiles.where((p) => p.realLabel.toLowerCase().contains(q)).toList();
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              appLocalizations.profileFiles,
              style: tokens?.groupTitleStyle.copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (profiles.isEmpty) {
                  return _EmptyState(
                    icon: Icons.description_outlined,
                    title: appLocalizations.noProfiles,
                    subtitle: appLocalizations.noProfilesDesc,
                    actionLabel: appLocalizations.addProfile,
                    onAction: onAdd,
                  );
                }
                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off_outlined,
                    title: appLocalizations.noSearchResult,
                    actionLabel: appLocalizations.clearSearch,
                    onAction: () {},
                  );
                }
                return SingleChildScrollView(
                  child: DesktopDragList<Profile>(
                    items: filtered,
                    itemExtent: 60,
                    onReorder: onReorder,
                    itemBuilder: (context, profile, index, handle) {
                      return _ProfileRow(
                        profile: profile,
                        selected: profile.id == selectedId,
                        isCurrent: profile.id == currentId,
                        handle: handle,
                        onTap: () => onSelect(profile.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends ConsumerStatefulWidget {
  const _ProfileRow({
    required this.profile,
    required this.selected,
    required this.isCurrent,
    required this.handle,
    required this.onTap,
  });

  final Profile profile;
  final bool selected;
  final bool isCurrent;
  final Widget handle;
  final VoidCallback onTap;

  @override
  ConsumerState<_ProfileRow> createState() => _ProfileRowState();
}

class _ProfileRowState extends ConsumerState<_ProfileRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final profile = widget.profile;
    final row = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onSecondaryTapUp: (details) =>
            _showRowMenu(context, details.globalPosition),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                : _hover
                ? DesktopThemeTokens.controlHoverOverlay
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 4,
            children: [
              widget.handle,
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCurrent
                      ? (tokens?.success ?? theme.colorScheme.primary)
                      : Colors.transparent,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      profile.realLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.selected
                            ? accent
                            : (tokens?.text1 ?? theme.colorScheme.onSurface),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profile.type == ProfileType.url
                          ? ProfileType.url.name
                          : ProfileType.file.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: row,
    );
  }

  Future<void> _showRowMenu(BuildContext context, Offset position) async {
    final appLocalizations = context.appLocalizations;
    final profile = widget.profile;
    final action = await showDesktopMenu<VoidCallback>(
      context: context,
      position: position,
      items: [
        DesktopMenuItem(
          label: appLocalizations.setAsDefault,
          icon: Icons.check_circle_outlined,
          value: () {
            ref.read(currentProfileIdProvider.notifier).value = profile.id;
          },
        ),
        DesktopMenuItem(
          label: appLocalizations.rename,
          icon: Icons.drive_file_rename_outline,
          value: () => _handleRename(context),
        ),
        DesktopMenuItem(
          label: appLocalizations.exportAction,
          icon: Icons.file_upload_outlined,
          value: () => _handleExport(context),
        ),
        const DesktopMenuDivider(),
        DesktopMenuItem(
          label: appLocalizations.delete,
          icon: Icons.delete_outlined,
          danger: true,
          value: () => _handleDelete(context),
        ),
      ],
    );
    action?.call();
  }

  Future<void> _handleRename(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final controller = TextEditingController(text: widget.profile.label);
    final label = await dialogs.showCommonDialog<String>(
      child: CommonDialog(
        title: appLocalizations.rename,
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextField(controller: controller, autofocus: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(appLocalizations.cancel),
                  ),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(controller.text.trim()),
                    child: Text(appLocalizations.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (label == null) return;
    ref
        .read(profilesProvider.notifier)
        .updateProfile(widget.profile.id, (p) => p.copyWith(label: label));
  }

  Future<void> _handleExport(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final ok = await globalState.safeRun<bool>(() async {
      final mFile = await widget.profile.file;
      final value = await picker.saveFile(
        widget.profile.realLabel,
        mFile.readAsBytesSync(),
      );
      return value != null;
    }, title: appLocalizations.tip);
    if (ok == true && context.mounted) {
      context.showNotifier(
        appLocalizations.exportSuccess,
        level: MessageLevel.success,
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.confirmDeleteTitle,
      message:
          '${widget.profile.realLabel}\n${appLocalizations.confirmDeleteMessage}',
      confirmLabel: appLocalizations.delete,
      danger: true,
    );
    if (!confirmed) return;
    await ref
        .read(profilesActionProvider.notifier)
        .deleteProfile(widget.profile.id);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(icon, size: 44, color: text3),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: text3),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(color: text3),
                textAlign: TextAlign.center,
              ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 4),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({
    required this.hasProfiles,
    required this.query,
    required this.onClearSearch,
    required this.onAdd,
  });

  final bool hasProfiles;
  final String query;
  final VoidCallback onClearSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (!hasProfiles) {
      return _EmptyState(
        icon: Icons.description_outlined,
        title: appLocalizations.noProfiles,
        subtitle: appLocalizations.noProfilesDesc,
        actionLabel: appLocalizations.addProfile,
        onAction: onAdd,
      );
    }
    return _EmptyState(
      icon: Icons.search_off_outlined,
      title: appLocalizations.noSearchResult,
      actionLabel: appLocalizations.clearSearch,
      onAction: query.isEmpty ? null : onClearSearch,
    );
  }
}

class _ProfileDetail extends ConsumerWidget {
  const _ProfileDetail({
    super.key,
    required this.profile,
    required this.isCurrent,
  });

  final Profile profile;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(desktopConfigTabProvider);
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailHeader(profile: profile, isCurrent: isCurrent),
          _DetailTabs(
            index: tabIndex,
            onChanged: (i) =>
                ref.read(desktopConfigTabProvider.notifier).value = i,
          ),
          Expanded(
            child: tabIndex == 0
                ? _NodesTab(profile: profile)
                : _RulesTab(profile: profile),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.profile, required this.isCurrent});

  final Profile profile;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  profile.realLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  profile.url.isEmpty ? ProfileType.file.name : profile.url,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    tokens?.accentSoft ??
                    theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.appLocalizations.inUse,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens?.accent ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final labels = [appLocalizations.nodes, appLocalizations.rules];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        spacing: 4,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == i ? accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: index == i ? FontWeight.w700 : FontWeight.w500,
                    color: index == i
                        ? accent
                        : (tokens?.text2 ?? theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodesTab extends ConsumerWidget {
  const _NodesTab({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: _NodesDashboard(groups: groups),
        ),
        Expanded(
          child: groups.isEmpty
              ? const _NodesEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _GroupSection(group: groups[i]),
                ),
        ),
      ],
    );
  }
}

/// Dashboard strip above the node list: live run state, current node and
/// traffic plus the node quick actions. The strip stays visible with zero
/// nodes so the page reads as a dashboard instead of a blank list.
class _NodesDashboard extends ConsumerWidget {
  const _NodesDashboard({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final isStart = ref.watch(isStartProvider);
    final status = ref.watch(coreStatusProvider);
    final lastTraffic = ref.watch(
      trafficsProvider.select((s) => s.list.safeLast(const Traffic())),
    );
    final currentName =
        groups.firstWhereOrNull((g) => (g.now ?? '').isNotEmpty)?.now ?? '';
    final statusText = switch (status) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
        ),
        color: tokens?.bg1 ?? theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 16,
            children: [
              _DashStat(
                label: appLocalizations.runStatus,
                value: statusText,
                dot: isStart
                    ? (tokens?.success ?? theme.colorScheme.primary)
                    : (tokens?.text3 ?? theme.colorScheme.onSurfaceVariant),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _DashStat(
                  label: appLocalizations.currentNode,
                  value: currentName.isEmpty ? '—' : currentName,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
              _DashStat(
                label: appLocalizations.upload,
                value: '${lastTraffic.up.traffic.show}/s',
                mono: true,
              ),
              _DashStat(
                label: appLocalizations.download,
                value: '${lastTraffic.down.traffic.show}/s',
                mono: true,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _testAll(ref),
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: Text(appLocalizations.delayTest),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(profilesActionProvider.notifier)
                      .addProfileFormFile(widgetRef: ref);
                },
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: Text(appLocalizations.import),
              ),
              FilledButton.icon(
                onPressed: () => _showAddSubscription(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(appLocalizations.addSubscription),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _testAll(WidgetRef ref) {
    final proxies = groups.expand((g) => g.all).toList();
    if (proxies.isEmpty) return;
    ref.read(proxiesActionProvider.notifier).delayTest(proxies);
  }

  void _showAddSubscription(BuildContext context) {
    unawaited(dialogs.showCommonDialog(child: const _AddProfileDialog()));
  }
}

class _DashStat extends StatelessWidget {
  const _DashStat({
    required this.label,
    required this.value,
    this.dot,
    this.mono = false,
  });

  final String label;
  final String value;
  final Color? dot;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
              ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: text3),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: mono ? DesktopThemeTokens.kpiFontFeatures : null,
            color: tokens?.text1 ?? theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Zero-node state: the dashboard strip above keeps the quick actions
/// visible, so this block only adds the entry-point CTAs.
class _NodesEmptyState extends ConsumerWidget {
  const _NodesEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text2 = tokens?.text2 ?? theme.colorScheme.onSurfaceVariant;
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: (tokens?.accent ?? theme.colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
              ),
              child: Icon(Icons.hub_outlined, size: 40, color: text3),
            ),
            Text(
              appLocalizations.noNodes,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: text2,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              appLocalizations.noNodesHint,
              style: theme.textTheme.bodySmall?.copyWith(color: text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _showAddNode(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(appLocalizations.addNode),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddSubscription(context),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: Text(appLocalizations.importSubscription),
                ),
                OutlinedButton.icon(
                  onPressed: _openDocs,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(appLocalizations.viewDocs),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNode(BuildContext context) {
    unawaited(dialogs.showCommonDialog(child: const _AddNodeDialog()));
  }

  void _showAddSubscription(BuildContext context) {
    unawaited(dialogs.showCommonDialog(child: const _AddProfileDialog()));
  }

  void _openDocs() {
    unawaited(dialogs.openUrl('https://github.com/Unwhimsical/Eclipse'));
  }
}

/// Paste-share-link dialog backing the empty state's add-node CTA.
class _AddNodeDialog extends ConsumerStatefulWidget {
  const _AddNodeDialog();

  @override
  ConsumerState<_AddNodeDialog> createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends ConsumerState<_AddNodeDialog> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.addNode,
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextField(
              controller: _linkController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: appLocalizations.nodeLinkHint,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: _handleConfirm,
                  child: Text(appLocalizations.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    final appLocalizations = context.appLocalizations;
    final text = _linkController.text.trim();
    Navigator.of(context).pop();
    if (text.isEmpty) return;
    await globalState.safeRun(() async {
      final label = await ShadowrocketImport.importShareLinks(ref, text: text);
      dialogs.showNotifier(
        label ?? appLocalizations.clipboardImportFailed,
        level: label == null ? MessageLevel.warning : MessageLevel.success,
      );
    }, title: appLocalizations.addNode);
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
              _ProxyCard(group: group, proxy: proxy),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Rich node card: name, protocol chip, group meta and a tappable latency
/// chip; the selected node carries an accent ring instead of a bare radio.
class _ProxyCard extends ConsumerStatefulWidget {
  const _ProxyCard({required this.group, required this.proxy});

  final Group group;
  final Proxy proxy;

  @override
  ConsumerState<_ProxyCard> createState() => _ProxyCardState();
}

class _ProxyCardState extends ConsumerState<_ProxyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final text1 = tokens?.text1 ?? theme.colorScheme.onSurface;
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    final selected = widget.group.now == widget.proxy.name;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSelect,
        onSecondaryTapUp: (details) =>
            _showMenu(context, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(
                DesktopThemeTokens.cardRadius,
              ),
              side: BorderSide(
                color: selected ? accent : Colors.white.withValues(alpha: 0.06),
                width: selected ? 1.5 : 1,
              ),
            ),
            color: selected
                ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                : _hover
                ? DesktopThemeTokens.controlHoverOverlay
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      widget.proxy.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? accent : text1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        _TypeChip(type: widget.proxy.type),
                        Flexible(
                          child: Text(
                            '${widget.group.name} · ${widget.group.type.value}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: text3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DelayChip(proxy: widget.proxy, testUrl: widget.group.testUrl),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSelect() {
    ref
        .read(proxiesActionProvider.notifier)
        .changeProxy(
          groupName: widget.group.name,
          proxyName: widget.proxy.name,
        );
  }

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final appLocalizations = context.appLocalizations;
    final link = await _shareLink();
    if (!context.mounted) return;
    final action = await showDesktopMenu<VoidCallback>(
      context: context,
      position: position,
      items: [
        DesktopMenuItem(
          label: appLocalizations.delayTest,
          icon: Icons.speed_rounded,
          value: () {
            ref.read(proxiesActionProvider.notifier).delayTest([widget.proxy]);
          },
        ),
        DesktopMenuItem(
          label: appLocalizations.setAsCurrent,
          icon: Icons.check_circle_outlined,
          value: _handleSelect,
        ),
        if (link != null)
          DesktopMenuItem(
            label: appLocalizations.copyLink,
            icon: Icons.link_rounded,
            value: () async {
              await Clipboard.setData(ClipboardData(text: link));
            },
          ),
      ],
    );
    action?.call();
  }

  /// Best-effort share link from the running config's raw proxy map.
  Future<String?> _shareLink() async {
    try {
      final profileId = ref.read(currentProfileIdProvider);
      if (profileId == null) return null;
      final raw = await ref
          .read(setupActionProvider.notifier)
          .getProfileWithId(profileId);
      final decoded = loadYaml(raw);
      if (decoded is! YamlMap) return null;
      final proxies = decoded['proxies'];
      if (proxies is! YamlList) return null;
      for (final item in proxies) {
        if (item is YamlMap && '${item['name']}' == widget.proxy.name) {
          return proxyToShareLink(
            item.map((k, v) => MapEntry('$k', _plain(v))),
          );
        }
      }
    } catch (_) {
      // Link copy stays unavailable when the raw config cannot be read.
    }
    return null;
  }

  dynamic _plain(dynamic value) {
    if (value is YamlMap) {
      return value.map((k, v) => MapEntry('$k', _plain(v)));
    }
    if (value is YamlList) {
      return value.map(_plain).toList();
    }
    return value is YamlScalar ? value.value : value;
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text2 = tokens?.text2 ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: text2.withValues(alpha: 0.35)),
        ),
      ),
      child: Text(
        type.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: text2,
          fontFeatures: DesktopThemeTokens.kpiFontFeatures,
        ),
      ),
    );
  }
}

/// Latency chip; tapping re-tests just this node.
class _DelayChip extends ConsumerWidget {
  const _DelayChip({required this.proxy, required this.testUrl});

  final Proxy proxy;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    final pending = ref.watch(
      delayTestPendingProvider(proxyName: proxy.name, testUrl: testUrl),
    );
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: testUrl),
    );
    final color = delay == null
        ? text3
        : delay <= 0
        ? (tokens?.danger ?? theme.colorScheme.error)
        : delay <= 200
        ? (tokens?.success ?? theme.colorScheme.primary)
        : delay <= 600
        ? (tokens?.warning ?? theme.colorScheme.primary)
        : (tokens?.danger ?? theme.colorScheme.error);
    final label = delay == null
        ? '—'
        : delay <= 0
        ? 'Timeout'
        : '$delay ms';
    return Tooltip(
      message: context.appLocalizations.delayTest,
      child: GestureDetector(
        onTap: () {
          ref
              .read(proxiesActionProvider.notifier)
              .proxyDelayTest(proxy, testUrl);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: color.withValues(alpha: 0.45)),
            ),
            color: color.withValues(alpha: 0.1),
          ),
          child: pending
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: DesktopThemeTokens.kpiFontFeatures,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}

class _RulesTab extends ConsumerStatefulWidget {
  const _RulesTab({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_RulesTab> createState() => _RulesTabState();
}

class _RulesTabState extends ConsumerState<_RulesTab> {
  String? _yaml;
  String _query = '';
  bool _overrideExpanded = false;
  final _ruleSearchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ruleSearchFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final raw = await ref
          .read(setupActionProvider.notifier)
          .getProfileWithId(widget.profile.id);
      if (!mounted) return;
      setState(() => _yaml = raw);
    } catch (_) {
      if (!mounted) return;
      setState(() => _yaml = '');
    }
  }

  List<String> get _ownRules {
    final yaml = _yaml;
    if (yaml == null) return [];
    final lines = yaml.split('\n');
    final rules = <String>[];
    var inRules = false;
    for (final line in lines) {
      if (!inRules) {
        if (line.trim() == 'rules:') inRules = true;
        continue;
      }
      if (line.startsWith('  - ') || line.startsWith('\t- ')) {
        rules.add(line.trim().substring(2).trim());
      } else if (line.trim().isNotEmpty && !line.startsWith(' ')) {
        break;
      }
    }
    final q = _query.toLowerCase();
    if (q.isEmpty) return rules;
    return rules.where((r) => r.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final rules = _ownRules;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            spacing: 12,
            children: [
              Text(
                appLocalizations.rulesReadonly,
                style: tokens?.groupTitleStyle.copyWith(fontSize: 13),
              ),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    focusNode: _ruleSearchFocus,
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchRules,
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _yaml == null
              ? const Center(child: CommonCircleLoading())
              : rules.isEmpty
              ? Center(
                  child: Text(
                    _query.isEmpty
                        ? appLocalizations.noRules
                        : appLocalizations.noSearchResult,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  itemCount: rules.length,
                  itemExtent: 30,
                  itemBuilder: (_, i) =>
                      _RuleLine(number: i + 1, text: rules[i]),
                ),
        ),
        _OverrideSection(
          profile: widget.profile,
          expanded: _overrideExpanded,
          onToggle: () =>
              setState(() => _overrideExpanded = !_overrideExpanded),
        ),
      ],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final mono = [
      DesktopThemeTokens.monoFontFamily,
      ...DesktopThemeTokens.monoFontFamilyFallback,
    ];
    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '$number',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
              fontFamily: mono.first,
              fontFamilyFallback: mono.sublist(1),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: mono.first,
              fontFamilyFallback: mono.sublist(1),
              color: tokens?.text2 ?? theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OverrideSection extends ConsumerWidget {
  const _OverrideSection({
    required this.profile,
    required this.expanded,
    required this.onToggle,
  });

  final Profile profile;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final rules = ref.watch(profileCustomRulesProvider(profile.id)).value ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  expanded
                      ? Icons.expand_more_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: tokens?.text2 ?? theme.colorScheme.onSurfaceVariant,
                ),
                Text(
                  '${appLocalizations.overrideRules} (${rules.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (expanded)
                  IconButton(
                    tooltip: appLocalizations.add,
                    iconSize: 18,
                    onPressed: () => _handleAdd(context, ref),
                    icon: const Icon(Icons.add_rounded),
                  ),
              ],
            ),
          ),
        ),
        if (expanded)
          SizedBox(
            height: 180,
            child: rules.isEmpty
                ? Center(
                    child: Text(
                      appLocalizations.noOverrideRules,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : DesktopDragList<Rule>(
                    items: rules,
                    itemExtent: 36,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(profileCustomRulesProvider(profile.id).notifier)
                          .order(oldIndex, newIndex);
                    },
                    itemBuilder: (context, rule, index, handle) {
                      return _OverrideRuleRow(
                        rule: rule,
                        handle: handle,
                        onDelete: () => _handleDelete(context, ref, rule),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final controller = TextEditingController();
    final text = await dialogs.showCommonDialog<String>(
      child: CommonDialog(
        title: appLocalizations.addRule,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'DOMAIN-SUFFIX,example.com,PROXY',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(appLocalizations.cancel),
                  ),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(controller.text.trim()),
                    child: Text(appLocalizations.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    try {
      final rule = Rule.parse(text);
      ref.read(profileCustomRulesProvider(profile.id).notifier).put(rule);
    } catch (_) {
      if (context.mounted) {
        context.showNotifier(
          appLocalizations.invalidRule,
          level: MessageLevel.error,
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Rule rule,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.confirmDeleteTitle,
      message: rule.rawValue,
      confirmLabel: appLocalizations.delete,
      danger: true,
    );
    if (!confirmed) return;
    ref.read(profileCustomRulesProvider(profile.id).notifier).delAll([rule.id]);
  }
}

class _OverrideRuleRow extends StatefulWidget {
  const _OverrideRuleRow({
    required this.rule,
    required this.handle,
    required this.onDelete,
  });

  final Rule rule;
  final Widget handle;
  final VoidCallback onDelete;

  @override
  State<_OverrideRuleRow> createState() => _OverrideRuleRowState();
}

class _OverrideRuleRowState extends State<_OverrideRuleRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final mono = [
      DesktopThemeTokens.monoFontFamily,
      ...DesktopThemeTokens.monoFontFamilyFallback,
    ];
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: _hover ? DesktopThemeTokens.controlHoverOverlay : null,
        child: Row(
          spacing: 8,
          children: [
            widget.handle,
            Expanded(
              child: Text(
                widget.rule.rawValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: mono.first,
                  fontFamilyFallback: mono.sublist(1),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_hover)
              IconButton(
                tooltip: context.appLocalizations.delete,
                iconSize: 16,
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete_outlined,
                  color: tokens?.danger ?? theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
