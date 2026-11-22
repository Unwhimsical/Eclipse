import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RouteChoice { rule, global, direct }

class RouteModeBar extends ConsumerWidget {
  const RouteModeBar({super.key});

  void _select(WidgetRef ref, RouteChoice choice) {
    if (ref.read(sceneModeEnabledProvider)) {
      ref.read(sceneModeEnabledProvider.notifier).update((_) => false);
    }
    ref.read(setupActionProvider.notifier).changeMode(switch (choice) {
      RouteChoice.rule => Mode.rule,
      RouteChoice.global => Mode.global,
      RouteChoice.direct => Mode.direct,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final sceneEnabled = ref.watch(sceneModeEnabledProvider);
    final groupValue = switch (mode) {
      Mode.global => RouteChoice.global,
      Mode.direct => RouteChoice.direct,
      _ => RouteChoice.rule,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EclipseSegmented<RouteChoice>(
          groupValue: groupValue,
          onChanged: (choice) => _select(ref, choice),
          options: [
            EclipseSegmentOption(
              value: RouteChoice.rule,
              label: appLocalizations.routeConfig,
            ),
            EclipseSegmentOption(
              value: RouteChoice.global,
              label: appLocalizations.routeProxy,
            ),
            EclipseSegmentOption(
              value: RouteChoice.direct,
              label: appLocalizations.routeDirect,
            ),
          ],
        ),
        if (sceneEnabled)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ref
                    .read(sceneModeEnabledProvider.notifier)
                    .update((_) => false);
              },
              child: Text(appLocalizations.routeScene),
            ),
          ),
      ],
    );
  }
}
