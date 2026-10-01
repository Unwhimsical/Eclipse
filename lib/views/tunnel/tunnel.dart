import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/general.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TunnelRoutesView extends ConsumerStatefulWidget {
  const TunnelRoutesView({super.key});

  @override
  ConsumerState<TunnelRoutesView> createState() => _TunnelRoutesViewState();
}

class _TunnelRoutesViewState extends ConsumerState<TunnelRoutesView> {
  final _excludedController = TextEditingController();
  final _includedController = TextEditingController();

  @override
  void dispose() {
    _excludedController.dispose();
    _includedController.dispose();
    super.dispose();
  }

  void _addRoute(int profileId, bool included) {
    final controller = included ? _includedController : _excludedController;
    final route = controller.text.trim();
    if (route.isEmpty) return;
    updateGeneralSettings(
      ref,
      profileId,
      (settings) => included
          ? settings.copyWith(
              tunIncludedRoutes: {
                ...settings.tunIncludedRoutes,
                route,
              }.toList(),
            )
          : settings.copyWith(
              tunExcludedRoutes: {
                ...settings.tunExcludedRoutes,
                route,
              }.toList(),
            ),
    );
    controller.clear();
  }

  void _removeRoute(int profileId, bool included, String route) {
    updateGeneralSettings(
      ref,
      profileId,
      (settings) => included
          ? settings.copyWith(
              tunIncludedRoutes: settings.tunIncludedRoutes
                  .where((r) => r != route)
                  .toList(),
            )
          : settings.copyWith(
              tunExcludedRoutes: settings.tunExcludedRoutes
                  .where((r) => r != route)
                  .toList(),
            ),
    );
  }

  Widget _buildRouteSection({
    required AppLocalizations appLocalizations,
    required int profileId,
    required String title,
    required List<String> routes,
    required TextEditingController controller,
    required bool included,
  }) {
    return generateSectionV2(
      title: title,
      items: [
        ListItem(
          title: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            onSubmitted: (_) => _addRoute(profileId, included),
            decoration: InputDecoration(
              hintText: appLocalizations.tunnelAddHint,
            ),
          ),
          trailing: IconButton(
            tooltip: appLocalizations.tunnelAdd,
            icon: const Icon(Icons.add_outlined),
            onPressed: () => _addRoute(profileId, included),
          ),
        ),
        if (routes.isEmpty)
          ListItem(
            leading: const Icon(Icons.inbox_outlined),
            title: Text(appLocalizations.tunnelEmpty),
          )
        else
          for (final route in routes)
            ListItem(
              leading: const Icon(Icons.route_outlined),
              title: Text(
                route,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              trailing: IconButton(
                tooltip: appLocalizations.tunnelRemove,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeRoute(profileId, included, route),
              ),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final settings = ref.watch(
      profile == null
          ? Provider<GeneralSettings?>((_) => null)
          : profileProvider(
              profile.id,
            ).select((state) => state?.generalSettings),
    );
    return CommonScaffold(
      title: appLocalizations.tunnel,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.tunnelDesc),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (profile == null || settings == null)
            generateSectionV2(
              items: [
                ListItem(
                  leading: const Icon(Icons.inbox_outlined),
                  title: Text(appLocalizations.tunnelNoProfile),
                ),
              ],
            )
          else ...[
            _buildRouteSection(
              appLocalizations: appLocalizations,
              profileId: profile.id,
              title: appLocalizations.tunnelExcluded,
              routes: settings.tunExcludedRoutes,
              controller: _excludedController,
              included: false,
            ),
            const SizedBox(height: 16),
            _buildRouteSection(
              appLocalizations: appLocalizations,
              profileId: profile.id,
              title: appLocalizations.tunnelIncluded,
              routes: settings.tunIncludedRoutes,
              controller: _includedController,
              included: true,
            ),
          ],
        ],
      ),
    );
  }
}
