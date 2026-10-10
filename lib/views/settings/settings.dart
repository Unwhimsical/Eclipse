import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/ca/ca.dart';
import 'package:fl_clash/views/compat_mode/compat_mode.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/views/delay_test/delay_test.dart';
import 'package:fl_clash/views/developer.dart';
import 'package:fl_clash/views/front_proxy/front_proxy.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/permissions/permissions.dart';
import 'package:fl_clash/views/proxy_share/proxy_share.dart';
import 'package:fl_clash/views/scene/scene_page.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/tunnel/tunnel.dart';
import 'package:fl_clash/views/tunnel/udp_stun.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show dirname, join;

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final developerMode = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return CommonScaffold(
      title: appLocalizations.settings,
      body: ListView(
        key: settingsStoreKey,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + BottomInsetScope.of(context),
        ),
        children: [
          EclipseSection(
            title: appLocalizations.settingsSectionDisplay,
            children: [
              const _LocaleItem(),
              EclipseOpenTile(
                icon: Icons.palette_outlined,
                title: appLocalizations.appearance,
                subtitle: appLocalizations.appearanceDesc,
                page: const AppearanceView(),
              ),
              EclipseOpenTile(
                icon: Icons.style_outlined,
                title: appLocalizations.theme,
                subtitle: appLocalizations.themeDesc,
                page: const ThemeView(),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.settingsSectionNetwork,
            children: [
              EclipseOpenTile(
                icon: Icons.speed_outlined,
                title: appLocalizations.delayTest,
                subtitle: appLocalizations.delayTestDesc,
                page: const DelayTestView(),
              ),
              EclipseOpenTile(
                icon: Icons.wifi_outlined,
                title: appLocalizations.onDemand,
                subtitle: appLocalizations.onDemandDesc,
                page: const OnDemandView(),
              ),
              EclipseOpenTile(
                icon: Icons.route_outlined,
                title: appLocalizations.tunnel,
                page: const TunnelRoutesView(),
              ),
              EclipseOpenTile(
                icon: Icons.share_outlined,
                title: appLocalizations.proxySharing,
                page: const ProxyShareView(),
              ),
              EclipseOpenTile(
                icon: Icons.compare_arrows_outlined,
                title: appLocalizations.frontProxy,
                page: const FrontProxyView(),
              ),
              EclipseOpenTile(
                icon: Icons.devices_outlined,
                title: appLocalizations.compatibilityMode,
                page: const CompatModeView(),
              ),
              EclipseOpenTile(
                icon: Icons.bolt_outlined,
                title: appLocalizations.udpForwardStun,
                page: const UdpStunView(),
              ),
              EclipseOpenTile(
                icon: Icons.auto_mode_outlined,
                title: appLocalizations.sceneMode,
                subtitle: appLocalizations.sceneModeDesc,
                page: const SceneView(),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.settingsSectionSecurity,
            children: [
              EclipseOpenTile(
                icon: Icons.verified_user_outlined,
                title: appLocalizations.caCenter,
                page: const CaView(),
              ),
              EclipseOpenTile(
                icon: Icons.privacy_tip_outlined,
                title: appLocalizations.permissionNotes,
                page: const PermissionsView(),
              ),
            ],
          ),
          EclipseSection(
            title: appLocalizations.other,
            children: [
              EclipseOpenTile(
                icon: Icons.info_outline,
                title: appLocalizations.about,
                page: const AboutView(),
              ),
              EclipseTile(
                icon: Icons.system_update_outlined,
                title: appLocalizations.checkUpdate,
                showChevron: false,
                onTap: () {
                  final commonAction = ref.read(commonActionProvider.notifier);
                  unawaited(
                    globalState
                        .safeRun(
                          request.checkForUpdate,
                          title: appLocalizations.checkUpdate,
                        )
                        .then(
                          (data) => commonAction.checkUpdateResultHandle(
                            data: data,
                            isUser: true,
                          ),
                        ),
                  );
                },
              ),
              EclipseOpenTile(
                icon: Icons.tune_outlined,
                title: appLocalizations.basicConfig,
                subtitle: appLocalizations.basicConfigDesc,
                page: const ConfigView(),
              ),
              EclipseOpenTile(
                icon: Icons.build_outlined,
                title: appLocalizations.advancedConfig,
                subtitle: appLocalizations.advancedConfigDesc,
                page: const AdvancedConfigView(),
              ),
              EclipseOpenTile(
                icon: Icons.settings_outlined,
                title: appLocalizations.application,
                subtitle: appLocalizations.applicationDesc,
                page: const ApplicationSettingView(),
              ),
              if (system.isDesktop)
                EclipseOpenTile(
                  icon: Icons.keyboard_outlined,
                  title: appLocalizations.hotkeyManagement,
                  subtitle: appLocalizations.hotkeyManagementDesc,
                  page: const HotKeyView(),
                ),
              if (system.isWindows) const _LoopbackItem(),
              if (system.isAndroid)
                EclipseOpenTile(
                  icon: Icons.view_list_outlined,
                  title: appLocalizations.accessControl,
                  subtitle: appLocalizations.accessControlDesc,
                  page: const AccessView(),
                ),
              const _DisclaimerItem(),
              if (developerMode)
                EclipseOpenTile(
                  icon: Icons.developer_board_outlined,
                  title: appLocalizations.developerMode,
                  page: const DeveloperView(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  String _getLocaleString(BuildContext context, Locale? locale) {
    if (locale == null) return context.appLocalizations.defaultText;
    return locale.label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final currentLocale = getLocaleForString(locale);
    return EclipseTile(
      icon: Icons.language_outlined,
      title: context.appLocalizations.language,
      trailing: Text(
        _getLocaleString(context, currentLocale),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      showChevron: true,
      onTap: () {
        unawaited(dialogs.showCommonDialog(child: const _LocaleDialog()));
      },
    );
  }
}

class _LocaleDialog extends ConsumerWidget {
  const _LocaleDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final currentLocale = getLocaleForString(locale);
    final options = [null, ...AppLocalizations.delegate.supportedLocales];
    return CommonDialog(
      title: appLocalizations.language,
      child: SizedBox(
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, index) {
            final option = options[index];
            return RadioListTile<Locale?>(
              value: option,
              groupValue: currentLocale,
              title: Text(
                option == null ? appLocalizations.defaultText : option.label,
              ),
              onChanged: (value) {
                ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(locale: value?.toString()),
                    );
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return EclipseTile(
      icon: Icons.lock_outline,
      title: context.appLocalizations.loopback,
      subtitle: context.appLocalizations.loopbackDesc,
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _DisclaimerItem extends ConsumerWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EclipseTile(
      icon: Icons.gavel_outlined,
      title: context.appLocalizations.disclaimer,
      showChevron: true,
      onTap: () async {
        final isDisclaimerAccepted = await dialogs.showDisclaimer();
        if (!isDisclaimerAccepted) {
          await ref.read(systemActionProvider.notifier).handleExit();
        }
      },
    );
  }
}
