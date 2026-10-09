import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// §2 danger confirm: the confirm button uses the danger fill (§1: hover
/// fills #DC2626, white text) for destructive actions.
Future<bool> showDesktopConfirm({
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = false,
}) async {
  final context = globalState.navigatorKey.currentContext;
  if (context == null) return false;
  final appLocalizations = context.appLocalizations;
  final result = await dialogs.showCommonDialog<bool>(
    child: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final tokens = theme.extension<DesktopThemeTokens>();
        return CommonDialog(
          title: title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: danger
                  ? FilledButton.styleFrom(
                      backgroundColor:
                          tokens?.danger ?? theme.colorScheme.error,
                      foregroundColor: Colors.white,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return tokens?.dangerHover ?? theme.colorScheme.error;
                        }
                        return tokens?.danger ?? theme.colorScheme.error;
                      }),
                    )
                  : null,
              child: Text(confirmLabel),
            ),
          ],
          child: SizedBox(width: 300, child: Text(message)),
        );
      },
    ),
  );
  return result == true;
}
