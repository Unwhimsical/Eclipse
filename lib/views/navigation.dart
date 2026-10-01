import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/views.dart';
import 'package:material_ui/material_ui.dart';

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
        builder: (_) =>
            const HomeView(key: GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        icon: const Icon(Icons.description_outlined),
        label: PageLabel.config,
        builder: (_) =>
            const ProfilesView(key: GlobalObjectKey(PageLabel.config)),
      ),
      NavigationItem(
        icon: const Icon(Icons.analytics_outlined),
        label: PageLabel.data,
        builder: (_) => const DataView(key: GlobalObjectKey(PageLabel.data)),
      ),
      NavigationItem(
        icon: const Icon(Icons.settings_outlined),
        label: PageLabel.settings,
        builder: (_) =>
            const SettingsView(key: GlobalObjectKey(PageLabel.settings)),
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
