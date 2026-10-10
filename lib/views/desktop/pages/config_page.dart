import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/rule.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/desktop/value_holder.dart';
import 'package:fl_clash/views/test_rules/rule_matcher.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail tab index for the desktop config page; the home page and the
/// command palette reset it before navigating here.
final desktopConfigTabProvider = valueHolder(0);

/// Desktop config page: 260px profile list left, per-profile editor right
/// with 规则|模块|策略组|通用|DNS tabs. Only the rules tab is implemented;
/// the rest are placeholders.
class DesktopConfigView extends ConsumerStatefulWidget {
  const DesktopConfigView({super.key});

  @override
  ConsumerState<DesktopConfigView> createState() => _DesktopConfigViewState();
}

class _DesktopConfigViewState extends ConsumerState<DesktopConfigView> {
  int? _selectedId;

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
        DesktopPageHeader(title: appLocalizations.config),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                SizedBox(
                  width: 260,
                  child: _ProfileListPanel(
                    profiles: profiles,
                    currentId: currentId,
                    selectedId: _selectedId,
                    onSelect: (id) => setState(() => _selectedId = id),
                    onAdd: _handleAddProfile,
                  ),
                ),
                Expanded(
                  child: selected == null
                      ? _EmptyDetail(onAdd: _handleAddProfile)
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

  void _handleAddProfile() {
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
    required this.onSelect,
    required this.onAdd,
  });

  final List<Profile> profiles;
  final int? currentId;
  final int? selectedId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final text3 =
        theme.extension<DesktopThemeTokens>()?.text3 ??
        theme.colorScheme.onSurfaceVariant;
    return DesktopCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonalIcon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(appLocalizations.addProfile),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: profiles.isEmpty
                ? Center(
                    child: Text(
                      appLocalizations.noProfiles,
                      style: theme.textTheme.bodySmall?.copyWith(color: text3),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: profiles.length,
                    itemExtent: 60,
                    itemBuilder: (_, index) {
                      final profile = profiles[index];
                      return _ProfileRow(
                        profile: profile,
                        selected: profile.id == selectedId,
                        isCurrent: profile.id == currentId,
                        onTap: () => onSelect(profile.id),
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
    required this.onTap,
  });

  final Profile profile;
  final bool selected;
  final bool isCurrent;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onSecondaryTapUp: (details) =>
              _showMenu(context, details.globalPosition),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: widget.selected
                  ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                  : _hover
                  ? DesktopThemeTokens.controlHoverOverlay
                  : Colors.transparent,
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        widget.profile.realLabel,
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
                        widget.profile.type == ProfileType.url
                            ? ProfileType.url.name
                            : ProfileType.file.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              tokens?.text3 ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isCurrent)
                  _InUseBadge(label: context.appLocalizations.inUse),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) async {
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
          label: appLocalizations.duplicateProfile,
          icon: Icons.content_copy_outlined,
          value: () => _handleDuplicate(context),
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

  Future<void> _handleDuplicate(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final profile = widget.profile;
    final core = ref.read(coreHandlerProvider);
    final newProfile = await globalState.safeRun<Profile>(() async {
      final bytes = await (await profile.file).readAsBytes();
      return Profile.normal(
        label: '${profile.realLabel} ${appLocalizations.profileCopySuffix}',
      ).saveFile(bytes, validate: core.validateConfig);
    }, title: appLocalizations.duplicateProfile);
    if (newProfile != null) {
      ref.read(profilesActionProvider.notifier).putProfile(newProfile);
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

class _InUseBadge extends StatelessWidget {
  const _InUseBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        color: tokens?.accentSoft ?? accent.withValues(alpha: 0.14),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final text3 =
        theme.extension<DesktopThemeTokens>()?.text3 ??
        theme.colorScheme.onSurfaceVariant;
    return DesktopCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.description_outlined, size: 44, color: text3),
            Text(
              appLocalizations.noProfiles,
              style: theme.textTheme.titleSmall?.copyWith(color: text3),
            ),
            Text(
              appLocalizations.noProfilesDesc,
              style: theme.textTheme.bodySmall?.copyWith(color: text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: onAdd,
              child: Text(appLocalizations.addProfile),
            ),
          ],
        ),
      ),
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
            child: switch (tabIndex) {
              0 => _RulesTab(profile: profile),
              1 => const _ModulesTab(),
              _ => _TabPlaceholder(index: tabIndex),
            },
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
          if (isCurrent) _InUseBadge(label: context.appLocalizations.inUse),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  List<String> _labels(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      appLocalizations.rules,
      appLocalizations.modules,
      appLocalizations.proxyGroup,
      appLocalizations.generalSection,
      'DNS',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    final labels = _labels(context);
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
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: index == i
                      ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.14))
                      : Colors.transparent,
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

class _RulesTab extends ConsumerStatefulWidget {
  const _RulesTab({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_RulesTab> createState() => _RulesTabState();
}

class _RulesTabState extends ConsumerState<_RulesTab> {
  String _query = '';
  bool _textMode = false;

  List<Rule> _filtered(List<Rule> rules) {
    if (_query.isEmpty) return rules;
    final q = _query.toLowerCase();
    return rules.where((r) => r.rawValue.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final rules =
        ref.watch(profileCustomRulesProvider(widget.profile.id)).value ?? [];
    final filtered = _filtered(rules);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchRules,
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.view_list_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.description_outlined, size: 18),
                  ),
                ],
                selected: {_textMode},
                onSelectionChanged: (selection) =>
                    setState(() => _textMode = selection.first),
              ),
              OutlinedButton.icon(
                onPressed: () => _handleTest(filtered),
                icon: const Icon(Icons.science_outlined, size: 18),
                label: Text(appLocalizations.testRules),
              ),
              FilledButton.icon(
                onPressed: _handleAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(appLocalizations.addRule),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
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
              : _textMode
              ? _RuleTextView(rules: filtered)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  itemCount: filtered.length,
                  itemExtent: 44,
                  itemBuilder: (_, index) {
                    final rule = filtered[index];
                    return _RuleRow(
                      rule: rule,
                      onTap: () => _handleEdit(rule),
                      onDelete: () => _handleDelete(rule),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handleAdd() async {
    final res = await dialogs.showCommonDialog<Rule>(
      child: const AddOrEditRuleDialog(),
    );
    if (res == null) return;
    ref.read(profileCustomRulesProvider(widget.profile.id).notifier).put(res);
  }

  Future<void> _handleEdit(Rule rule) async {
    final res = await dialogs.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) return;
    ref.read(profileCustomRulesProvider(widget.profile.id).notifier).put(res);
  }

  Future<void> _handleDelete(Rule rule) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await showDesktopConfirm(
      title: appLocalizations.confirmDeleteTitle,
      message: rule.rawValue,
      confirmLabel: appLocalizations.delete,
      danger: true,
    );
    if (!confirmed) return;
    ref.read(profileCustomRulesProvider(widget.profile.id).notifier).delAll([
      rule.id,
    ]);
  }

  void _handleTest(List<Rule> rules) {
    unawaited(
      dialogs.showCommonDialog(
        child: _TestRulesDialog(rules: rules.map((r) => r.rawValue).toList()),
      ),
    );
  }
}

class _RuleRow extends StatefulWidget {
  const _RuleRow({
    required this.rule,
    required this.onTap,
    required this.onDelete,
  });

  final Rule rule;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<_RuleRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = [
      DesktopThemeTokens.monoFontFamily,
      ...DesktopThemeTokens.monoFontFamilyFallback,
    ];
    final rule = widget.rule;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: _hover
                ? DesktopThemeTokens.controlHoverOverlay
                : Colors.transparent,
          ),
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 128,
                child: Text(
                  rule.ruleAction.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: mono.first,
                    fontFamilyFallback: mono.sublist(1),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  rule.realContent ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: mono.first,
                    fontFamilyFallback: mono.sublist(1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _ActionChip(target: (rule.realTarget ?? '').toUpperCase()),
              SizedBox(
                width: 32,
                child: _hover
                    ? IconButton(
                        tooltip: context.appLocalizations.delete,
                        iconSize: 18,
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outlined),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.target});

  final String target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final color = switch (target) {
      'REJECT' => Colors.orange,
      'DIRECT' => Colors.green,
      'PROXY' => tokens?.accent ?? theme.colorScheme.primary,
      _ => tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        color: color.withValues(alpha: 0.14),
      ),
      child: Text(
        target.isEmpty ? '-' : target,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RuleTextView extends StatelessWidget {
  const _RuleTextView({required this.rules});

  final List<Rule> rules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final mono = [
      DesktopThemeTokens.monoFontFamily,
      ...DesktopThemeTokens.monoFontFamilyFallback,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: SelectableText(
        rules.map((rule) => rule.rawValue).join('\n'),
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: mono.first,
          fontFamilyFallback: mono.sublist(1),
          color: tokens?.text2 ?? theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TestRulesDialog extends StatefulWidget {
  const _TestRulesDialog({required this.rules});

  final List<String> rules;

  @override
  State<_TestRulesDialog> createState() => _TestRulesDialogState();
}

class _TestRulesDialogState extends State<_TestRulesDialog> {
  final _inputController = TextEditingController();
  final _portController = TextEditingController(text: '443');
  String _network = 'TCP';
  RuleMatchVerdict? _verdict;
  bool _tested = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _handleTest() {
    final appLocalizations = context.appLocalizations;
    final input = _inputController.text.trim();
    final target = TestTarget.parse(
      input,
      int.tryParse(_portController.text.trim()) ?? 443,
      _network,
    );
    if (input.isEmpty || target == null) {
      setState(() {
        _error = appLocalizations.testRulesEmptyInput;
        _tested = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _tested = true;
      _verdict = findFirstMatch(widget.rules, target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    return CommonDialog(
      title: appLocalizations.testRules,
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              appLocalizations.testRulesDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: appLocalizations.testRulesInputLabel,
                hintText: appLocalizations.testRulesInputHint,
                errorText: _error,
              ),
              onSubmitted: (_) => _handleTest(),
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: appLocalizations.testRulesPortLabel,
                    ),
                  ),
                ),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'TCP', label: Text('TCP')),
                    ButtonSegment(value: 'UDP', label: Text('UDP')),
                  ],
                  selected: {_network},
                  onSelectionChanged: (selection) =>
                      setState(() => _network = selection.first),
                ),
              ],
            ),
            FilledButton(
              onPressed: _handleTest,
              child: Text(appLocalizations.testRulesTest),
            ),
            if (_tested)
              _TestResultView(
                verdict: _verdict,
                ruleCount: widget.rules.length,
              ),
          ],
        ),
      ),
    );
  }
}

class _TestResultView extends StatelessWidget {
  const _TestResultView({required this.verdict, required this.ruleCount});

  final RuleMatchVerdict? verdict;
  final int ruleCount;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final mono = [
      DesktopThemeTokens.monoFontFamily,
      ...DesktopThemeTokens.monoFontFamilyFallback,
    ];
    final verdict = this.verdict;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: tokens?.bg3 ?? theme.colorScheme.surfaceContainerHighest,
      ),
      child: verdict == null
          ? Row(
              spacing: 8,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                Expanded(child: Text(appLocalizations.testRulesNoMatch)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      verdict.certain ? Icons.gps_fixed : Icons.help_outline,
                      size: 18,
                      color: verdict.certain ? Colors.green : Colors.orange,
                    ),
                    Expanded(
                      child: Text(
                        appLocalizations.testRulesMatchedRule,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SelectableText(
                  verdict.rawRule,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: mono.first,
                    fontFamilyFallback: mono.sublist(1),
                  ),
                ),
                Text(
                  appLocalizations.testRulesRuleOrder(
                    '${verdict.index + 1}',
                    '$ruleCount',
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (verdict.target != null)
                  Text(
                    '${appLocalizations.statConnPolicy}: ${verdict.target}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (!verdict.certain)
                  Row(
                    spacing: 8,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                      Expanded(
                        child: Text(
                          appLocalizations.testRulesUnsupportedRule,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

String _extractSection(String raw, String sectionName) {
  final buffer = <String>[];
  var inSection = false;
  final target = sectionName.toLowerCase();
  for (final line in const LineSplitter().convert(raw)) {
    final trimmed = line.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      if (inSection) break;
      final name = trimmed
          .substring(1, trimmed.length - 1)
          .trim()
          .toLowerCase();
      if (name == target) inSection = true;
      continue;
    }
    if (inSection) buffer.add(line);
  }
  while (buffer.isNotEmpty && buffer.last.trim().isEmpty) {
    buffer.removeLast();
  }
  return buffer.join('\n');
}

String _replaceSection(String raw, String sectionName, String newContent) {
  final lines = const LineSplitter().convert(raw);
  final result = <String>[];
  var inSection = false;
  var found = false;
  final target = sectionName.toLowerCase();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final name = trimmed
          .substring(1, trimmed.length - 1)
          .trim()
          .toLowerCase();
      if (inSection) {
        if (newContent.trim().isNotEmpty) result.add(newContent);
        inSection = false;
      }
      if (name == target) {
        inSection = true;
        found = true;
      }
      result.add(line);
      continue;
    }
    if (!inSection) result.add(line);
  }
  if (inSection && newContent.trim().isNotEmpty) result.add(newContent);
  if (!found) {
    result.add('');
    result.add('[$sectionName]');
    result.add(newContent);
  }
  return result.join('\n');
}

class _ModulesTab extends ConsumerStatefulWidget {
  const _ModulesTab();

  @override
  ConsumerState<_ModulesTab> createState() => _ModulesTabState();
}

class _ModulesTabState extends ConsumerState<_ModulesTab> {
  List<ModuleInfo> _modules = [];
  bool _loading = true;
  String _query = '';
  String? _selectedId;

  String? _raw;
  int _sectionIndex = 0;
  final Map<int, TextEditingController> _editors = {};
  final Set<int> _changed = {};
  bool _saving = false;

  static const _sections = [
    ('rule', '规则'),
    ('url rewrite', 'URL重写'),
    ('script', '脚本'),
    ('mitm', 'MITM'),
    ('host', 'Host'),
  ];

  static const _largeSectionLimit = 100 * 1024;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    for (final c in _editors.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    List<ModuleInfo> modules = const [];
    try {
      modules = await moduleStore.list();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _modules = modules;
      _loading = false;
      if (_selectedId != null && modules.every((m) => m.id != _selectedId)) {
        _selectedId = null;
        _clearEditor();
      }
      _selectedId ??= modules.firstOrNull?.id;
    });
    if (_selectedId != null && _raw == null) {
      await _loadModule(_selectedId!);
    }
  }

  void _clearEditor() {
    for (final c in _editors.values) {
      c.dispose();
    }
    _editors.clear();
    _changed.clear();
    _raw = null;
    _sectionIndex = 0;
  }

  Future<void> _loadModule(String id) async {
    _clearEditor();
    final raw = await moduleStore.readRaw(id);
    if (!mounted) return;
    setState(() {
      _selectedId = id;
      _raw = raw ?? '';
    });
    _openSection(0);
  }

  void _openSection(int index) {
    final old = _editors[index];
    if (old != null) {
      setState(() => _sectionIndex = index);
      return;
    }
    final content = _raw == null
        ? ''
        : _extractSection(_raw!, _sections[index].$1);
    final controller = TextEditingController(text: content);
    controller.addListener(() => _changed.add(index));
    _editors[index] = controller;
    setState(() => _sectionIndex = index);
  }

  Future<void> _save() async {
    final id = _selectedId;
    final raw = _raw;
    if (id == null || raw == null || _saving || _changed.isEmpty) return;
    setState(() => _saving = true);
    try {
      var updated = raw;
      for (final index in _changed) {
        final controller = _editors[index];
        if (controller != null) {
          updated = _replaceSection(
            updated,
            _sections[index].$1,
            controller.text,
          );
        }
      }
      final info = await globalState.safeRun(
        () => moduleStore.updateContent(id, updated),
      );
      if (!mounted) return;
      if (info != null) {
        _clearEditor();
        await _refresh();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggle(ModuleInfo info, bool enabled) async {
    await globalState.safeRun(
      () => ShadowrocketImport.setModuleEnabled(ref, info, enabled),
    );
    await _refresh();
  }

  Future<void> _delete(ModuleInfo info) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteModuleConfirm(info.name)),
    );
    if (confirmed != true) return;
    if (info.enabled) {
      await ShadowrocketImport.setModuleEnabled(ref, info, false);
    }
    await moduleStore.delete(info.id);
    await _refresh();
  }

  Future<void> _importFromFile() async {
    final appLocalizations = context.appLocalizations;
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null || !mounted) return;
    final bytes = await platformFile.readBytes();
    final info = await globalState.safeRun(
      () => ShadowrocketImport.importModule(
        ref,
        raw: String.fromCharCodes(bytes),
        fileName: platformFile.name,
      ),
    );
    if (!mounted) return;
    if (info == null) {
      dialogs.showNotifier(
        appLocalizations.moduleInvalid,
        level: MessageLevel.warning,
      );
      return;
    }
    dialogs.showNotifier(
      appLocalizations.moduleImported(info.name),
      level: MessageLevel.success,
    );
    await _refresh();
  }

  Future<void> _importFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        hintText: 'https://example.com/module.sgmodule',
        value: '',
        keyboardType: TextInputType.url,
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) return appLocalizations.urlTip('').trim();
          return null;
        },
      ),
    );
    if (url == null || url.isEmpty || !mounted) return;
    final info = await globalState.safeRun(
      () => ShadowrocketImport.importModuleFromUrl(ref, url: url),
    );
    if (!mounted) return;
    if (info == null) {
      dialogs.showNotifier(
        appLocalizations.moduleDownloadFailed,
        level: MessageLevel.warning,
      );
      return;
    }
    dialogs.showNotifier(
      appLocalizations.moduleImported(info.name),
      level: MessageLevel.success,
    );
    await _refresh();
  }

  void _showImportMenu() {
    final appLocalizations = context.appLocalizations;
    dialogs.showCommonDialog(
      child: CommonDialog(
        title: appLocalizations.importModule,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.file_open),
              title: Text(appLocalizations.importModuleFromFile),
              onTap: () {
                Navigator.of(context).pop();
                _importFromFile();
              },
            ),
            ListItem(
              leading: const Icon(Icons.link),
              title: Text(appLocalizations.importFromUrl),
              onTap: () {
                Navigator.of(context).pop();
                _importFromUrl();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<ModuleInfo> get _filtered {
    if (_query.isEmpty) return _modules;
    final q = _query.toLowerCase();
    return _modules
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.desc.toLowerCase().contains(q),
        )
        .toList();
  }

  Widget _buildModuleRow(ModuleInfo info) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final selected = info.id == _selectedId;
    final accent = tokens?.accent ?? theme.colorScheme.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _loadModule(info.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(10),
            side: selected
                ? BorderSide(color: accent, width: 1.5)
                : BorderSide.none,
          ),
          color: selected
              ? (tokens?.accentSoft ?? accent.withValues(alpha: 0.12))
              : Colors.transparent,
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              Icons.extension_outlined,
              size: 20,
              color: info.enabled
                  ? accent
                  : (tokens?.text3 ?? theme.colorScheme.onSurfaceVariant),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    info.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    appLocalizations.moduleStatsSummary(
                      info.ruleCount,
                      info.rewriteCount,
                      info.scriptCount,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Switch(value: info.enabled, onChanged: (v) => _toggle(info, v)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: appLocalizations.delete,
              onPressed: () => _delete(info),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final info = _modules.firstWhereOrNull((m) => m.id == _selectedId);
    if (info == null) {
      return Center(
        child: Text(
          appLocalizations.noModulesDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final controller = _editors[_sectionIndex];
    final isLarge =
        controller != null && controller.text.length > _largeSectionLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      info.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (info.desc.isNotEmpty)
                      Text(
                        info.desc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              tokens?.text3 ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (_changed.isNotEmpty)
                OutlinedButton(
                  onPressed: () {
                    _clearEditor();
                    _loadModule(info.id);
                  },
                  child: Text(appLocalizations.reset),
                ),
              FilledButton.icon(
                onPressed: _changed.isEmpty || _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(appLocalizations.save),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 4,
            children: [
              for (var i = 0; i < _sections.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openSection(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: _sectionIndex == i
                          ? (tokens?.accentSoft ??
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.14,
                                ))
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Text(
                          _sections[i].$2,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: _sectionIndex == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _sectionIndex == i
                                ? (tokens?.accent ?? theme.colorScheme.primary)
                                : (tokens?.text2 ??
                                      theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        if (_changed.contains(i))
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: isLarge
                ? Center(
                    child: Text(
                      appLocalizations.moduleSectionTooLarge,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : controller == null
                ? const Center(child: CircularProgressIndicator())
                : TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontFamilyFallback: const ['Menlo', 'Consolas'],
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          tokens?.bg1 ?? theme.colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      hintText: appLocalizations.moduleSectionEmptyHint,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchModules,
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _showImportMenu,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(appLocalizations.importModule),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 300,
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          appLocalizations.noModulesDesc,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).extension<DesktopThemeTokens>()?.text3 ??
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _buildModuleRow(_filtered[i]),
                      ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _buildEditor()),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.index});

  final int index;

  static const _icons = [
    Icons.rule_outlined,
    Icons.extension_outlined,
    Icons.hub_outlined,
    Icons.tune_outlined,
    Icons.dns_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final theme = Theme.of(context);
    final text3 =
        theme.extension<DesktopThemeTokens>()?.text3 ??
        theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            _icons[index.clamp(0, _icons.length - 1)],
            size: 44,
            color: text3,
          ),
          Text(
            appLocalizations.comingSoon,
            style: theme.textTheme.bodyMedium?.copyWith(color: text3),
          ),
        ],
      ),
    );
  }
}
