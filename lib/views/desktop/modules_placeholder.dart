import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/desktop/page_header.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Stand-in for the module page (built by the page pass); keeps nav slot 5 alive.
class DesktopModulesPlaceholder extends StatelessWidget {
  const DesktopModulesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesktopThemeTokens>();
    return Column(
      children: [
        DesktopPageHeader(title: context.appLocalizations.modules),
        Expanded(
          child: Center(
            child: Icon(
              Icons.extension_outlined,
              size: 64,
              color:
                  tokens?.text3 ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
