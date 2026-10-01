import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/ca/ca.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/config/line_editors.dart';
import 'package:fl_clash/views/modules/modules.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/groups.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/views/rewrite/body_rewrite_editor.dart';
import 'package:fl_clash/views/rewrite/map_local_editor.dart';
import 'package:fl_clash/views/rules/rules.dart';
import 'package:fl_clash/views/test_rules/test_rules.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigDetailPage extends ConsumerWidget {
  final Profile profile;

  const ConfigDetailPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: profile.realLabel,
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + BottomInsetScope.of(context),
        ),
        children: [
          EclipseSection(
            title: appLocalizations.basicConfig,
            children: [
              EclipseOpenTile(
                title: appLocalizations.generalSection,
                icon: Icons.tune_outlined,
                page: EditProfileView(profile: profile, context: context),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.proxies,
            children: [
              EclipseOpenTile(
                title: appLocalizations.proxyServers,
                icon: Icons.dns_outlined,
                page: const ProxiesView(),
              ),
              EclipseOpenTile(
                title: appLocalizations.proxyGroups,
                icon: Icons.account_tree_outlined,
                page: CustomProxyGroupsView(profile.id),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.rules,
            children: [
              EclipseOpenTile(
                title: appLocalizations.rules,
                icon: Icons.rule_outlined,
                page: const RulesView(),
              ),
              EclipseOpenTile(
                title: appLocalizations.testRules,
                icon: Icons.science_outlined,
                page: const TestRulesView(),
              ),
              EclipseOpenTile(
                title: appLocalizations.hostSection,
                icon: Icons.storage_outlined,
                page: HostEditorPage(profileId: profile.id),
              ),
              EclipseOpenTile(
                title: appLocalizations.urlRewrite,
                icon: Icons.link_outlined,
                page: UrlRewriteEditorPage(profileId: profile.id),
              ),
              EclipseOpenTile(
                title: appLocalizations.headerRewrite,
                icon: Icons.view_headline_outlined,
                page: HeaderRewriteEditorPage(profileId: profile.id),
              ),
              EclipseOpenTile(
                title: appLocalizations.bodyRewrite,
                icon: Icons.article_outlined,
                page: BodyRewriteEditorPage(profileId: profile.id),
              ),
              EclipseOpenTile(
                title: appLocalizations.mapLocal,
                icon: Icons.map_outlined,
                page: MapLocalEditorPage(profileId: profile.id),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.other,
            children: [
              EclipseOpenTile(
                title: appLocalizations.httpsDecryption,
                icon: Icons.lock_outline,
                page: const CaView(),
              ),
              EclipseOpenTile(
                title: appLocalizations.script,
                icon: Icons.code_outlined,
                page: const ScriptsView(),
              ),
              EclipseOpenTile(
                title: appLocalizations.modules,
                icon: Icons.extension_outlined,
                page: const ModulesView(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
