import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  Future<void> _openSettings() async {
    await app?.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.permissions,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.permissionsDesc),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(appLocalizations.permLocation),
                subtitle: Text(appLocalizations.permLocationDesc),
              ),
              ListItem(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(appLocalizations.permNotification),
                subtitle: Text(appLocalizations.permNotificationDesc),
              ),
              ListItem(
                leading: const Icon(Icons.content_paste_outlined),
                title: Text(appLocalizations.permClipboard),
                subtitle: Text(appLocalizations.permClipboardDesc),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.settings_outlined),
                title: Text(appLocalizations.permOpenSettings),
                subtitle: Text(appLocalizations.permOpenSettingsDesc),
                onTap: _openSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
