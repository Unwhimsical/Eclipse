import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/scene_mode.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/ca/ca.dart';
import 'package:fl_clash/views/rewrite/rewrite_menu.dart';
import 'package:fl_clash/views/scene/scene_page.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    final description = navigationItem.label.description;
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(navigationItem.label.label),
      subtitle: description != null ? Text(description) : null,
      widget: navigationItem.builder(context),
      maxWidth: 400,
      forceFull: false,
    );
  }

  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return Column(
      children: [
        for (final navigationItem in navigationItems) ...[
          _buildNavigationMenuItem(navigationItem),
          navigationItems.last != navigationItem
              ? const Divider(height: 0)
              : Container(),
        ],
      ],
    );
  }

  List<Widget> _getToolList() {
    return generateSection(
      title: context.appLocalizations.tools,
      items: [
        if (system.isMobile) const _SceneModeItem(),
        const _RewriteItem(),
        if (system.isMobile) const _CaItem(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return Column(
            children: [
              ListHeader(title: context.appLocalizations.more),
              _buildNavigationMenu(state.navigationItems),
            ],
          );
        },
      ),
      ..._getToolList(),
    ];
    return CommonScaffold(
      title: context.appLocalizations.tools,
      body: ListView.builder(
        key: toolsStoreKey,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
        padding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

class _SceneModeItem extends StatelessWidget {
  const _SceneModeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.auto_awesome),
      title: Text(context.appLocalizations.sceneMode),
      subtitle: Text(
        sceneModeEntrySubtitle(
          isIOS: system.isIOS,
          base: context.appLocalizations.sceneModeDesc,
        ),
      ),
      widget: const SceneView(),
    );
  }
}

class _RewriteItem extends ConsumerWidget {
  const _RewriteItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      leading: const Icon(Icons.tune),
      title: Text(appLocalizations.rewrite),
      subtitle: Text(
        '${appLocalizations.mapLocal} / ${appLocalizations.bodyRewrite}',
      ),
      onTap: () => showRewriteMenu(context, ref),
    );
  }
}

class _CaItem extends StatelessWidget {
  const _CaItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.verified),
      title: Text(context.appLocalizations.caCenter),
      subtitle: Text(context.appLocalizations.caCenterDesc),
      widget: const CaView(),
    );
  }
}
