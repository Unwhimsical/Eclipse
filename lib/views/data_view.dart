import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/views/resources.dart';
import 'package:fl_clash/views/statistics/statistics.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/wifi_upload/wifi_upload.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class DataView extends StatelessWidget {
  const DataView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.data,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EclipseSection(
            title: appLocalizations.data,
            children: [
              EclipseOpenTile(
                icon: Icons.cloud_sync_outlined,
                title: appLocalizations.backupAndRestore,
                subtitle: appLocalizations.backupAndRestoreDesc,
                page: const BackupAndRestore(),
              ),
              EclipseOpenTile(
                icon: Icons.adb_outlined,
                title: appLocalizations.logs,
                subtitle: appLocalizations.logsDesc,
                page: const LogsView(),
              ),
              EclipseOpenTile(
                icon: Icons.query_stats_outlined,
                title: appLocalizations.statistics,
                page: const StatisticsView(),
              ),
              EclipseOpenTile(
                icon: Icons.ballot_outlined,
                title: appLocalizations.connections,
                subtitle: appLocalizations.connectionsDesc,
                page: const ConnectionsView(),
              ),
              EclipseOpenTile(
                icon: Icons.view_timeline_outlined,
                title: appLocalizations.requests,
                subtitle: appLocalizations.requestsDesc,
                page: const RequestsView(),
              ),
              EclipseOpenTile(
                icon: Icons.import_export_rounded,
                title: appLocalizations.nodeImportExport,
                page: const WifiUploadView(),
              ),
              EclipseOpenTile(
                icon: Icons.public_outlined,
                title: appLocalizations.geoUpdate,
                subtitle: appLocalizations.resourcesDesc,
                page: const ResourcesView(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
