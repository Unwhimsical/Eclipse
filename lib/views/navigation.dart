import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/views/views.dart';
import 'package:material_ui/material_ui.dart';

/// Desktop pages take over when the desktop theme tokens are present;
/// mobile keeps the original views untouched.
bool _isDesktop(BuildContext context) {
  return Theme.of(context).extension<DesktopThemeTokens>() != null;
}

class Navigation implements NavigationPort {
  static Navigation? _instance;

  @override
  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        keep: false,
        icon: const Icon(Icons.home_rounded),
        label: PageLabel.dashboard,
        builder: (context) => _isDesktop(context)
            ? const DesktopHomeView(key: GlobalObjectKey(PageLabel.dashboard))
            : const HomeView(key: GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        icon: const Icon(Icons.description_outlined),
        label: PageLabel.config,
        builder: (context) => _isDesktop(context)
            ? const DesktopConfigView(key: GlobalObjectKey(PageLabel.config))
            : const ProfilesView(key: GlobalObjectKey(PageLabel.config)),
      ),
      NavigationItem(
        icon: const Icon(Icons.extension_outlined),
        label: PageLabel.modules,
        modes: const [NavigationItemMode.desktop],
        builder: (_) =>
            const DesktopModulesView(key: GlobalObjectKey(PageLabel.modules)),
      ),
      NavigationItem(
        icon: const Icon(Icons.analytics_outlined),
        label: PageLabel.data,
        builder: (context) => _isDesktop(context)
            ? const DesktopDataView(key: GlobalObjectKey(PageLabel.data))
            : const DataView(key: GlobalObjectKey(PageLabel.data)),
      ),
      NavigationItem(
        icon: const Icon(Icons.settings_outlined),
        label: PageLabel.settings,
        builder: (context) => _isDesktop(context)
            ? const DesktopSettingsView(
                key: GlobalObjectKey(PageLabel.settings),
              )
            : const SettingsView(key: GlobalObjectKey(PageLabel.settings)),
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();
