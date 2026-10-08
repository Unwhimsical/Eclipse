import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// In-page top bar template (§2): big title left, per-page actions right.
class DesktopPageHeader extends StatelessWidget {
  const DesktopPageHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.extension<DesktopThemeTokens>()?.pageTitleStyle ??
        theme.textTheme.headlineSmall;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        spacing: 12,
        children: [
          Expanded(child: Text(title, style: titleStyle)),
          ...actions,
        ],
      ),
    );
  }
}
