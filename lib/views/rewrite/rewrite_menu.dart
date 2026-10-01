import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'body_rewrite_editor.dart';
import 'map_local_editor.dart';

void openRewritePage(BuildContext context, WidgetRef ref, bool isMapLocal) {
  final profileId = ref.read(currentProfileIdProvider);
  if (profileId == null) {
    dialogs.showNotifier(
      context.appLocalizations.noProfileSelected,
      level: MessageLevel.warning,
    );
    return;
  }
  BaseNavigator.push(
    context,
    isMapLocal
        ? MapLocalEditorPage(profileId: profileId)
        : BodyRewriteEditorPage(profileId: profileId),
  );
}

Future<void> showRewriteMenu(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  return dialogs.showCommonDialog(
    child: CommonDialog(
      title: appLocalizations.rewrite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem(
            leading: const Icon(Icons.map),
            title: Text(appLocalizations.mapLocal),
            subtitle: Text(appLocalizations.mapLocalDesc),
            onTap: () {
              Navigator.of(context).pop();
              openRewritePage(context, ref, true);
            },
          ),
          ListItem(
            leading: const Icon(Icons.data_object),
            title: Text(appLocalizations.bodyRewrite),
            subtitle: Text(appLocalizations.bodyRewriteDesc),
            onTap: () {
              Navigator.of(context).pop();
              openRewritePage(context, ref, false);
            },
          ),
        ],
      ),
    ),
  );
}
