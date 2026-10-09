import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Run toggle pinned to every desktop page header (§2); mirrors the home
/// page power button. The on-track is the §1 accent via the desktop theme.
class DesktopRunSwitch extends ConsumerWidget {
  const DesktopRunSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    final tokens = Theme.of(context).extension<DesktopThemeTokens>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isStart
                ? (tokens?.success ?? Theme.of(context).colorScheme.primary)
                : (tokens?.text3 ??
                      Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          isStart ? appLocalizations.running : appLocalizations.stopped,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color:
                tokens?.text2 ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Switch(
          value: isStart,
          onChanged: (_) {
            ref.read(commonActionProvider.notifier).toggleRunning();
          },
        ),
      ],
    );
  }
}
