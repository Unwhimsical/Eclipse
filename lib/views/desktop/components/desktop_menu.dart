import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// One row of a desktop context menu (§3.2).
class DesktopMenuItem<T> extends PopupMenuEntry<T> {
  const DesktopMenuItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.danger = false,
    this.checked = false,
  });

  final String label;
  final T value;
  final IconData? icon;
  final bool danger;
  final bool checked;

  @override
  double get height => 36;

  @override
  bool represents(T? value) => value == this.value;

  @override
  State<DesktopMenuItem<T>> createState() => _DesktopMenuItemState<T>();
}

class _DesktopMenuItemState<T> extends State<DesktopMenuItem<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final danger = widget.danger;
    final fg = danger
        ? (tokens?.danger ?? theme.colorScheme.error)
        : (tokens?.text1 ?? theme.colorScheme.onSurface);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(widget.value),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _hover
                ? (tokens?.bg3 ?? theme.colorScheme.surfaceContainerHighest)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            spacing: 10,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, size: 18, color: fg.withValues(alpha: 0.9)),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.checked)
                Icon(Icons.check_rounded, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divider row for a desktop context menu (§3.2).
class DesktopMenuDivider<T> extends PopupMenuEntry<T> {
  const DesktopMenuDivider({super.key});

  @override
  double get height => 9;

  @override
  bool represents(T? value) => false;

  @override
  State<DesktopMenuDivider<T>> createState() => _DesktopMenuDividerState<T>();
}

class _DesktopMenuDividerState<T> extends State<DesktopMenuDivider<T>> {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 9,
      thickness: 1,
      indent: 12,
      endIndent: 12,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }
}

/// §3.2 context menu: radius 12, bg2 + 1px border, 36px rows, bg3 hover,
/// danger rows in the danger color.
Future<T?> showDesktopMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<PopupMenuEntry<T>> items,
}) {
  final theme = Theme.of(context);
  final tokens = theme.extension<DesktopThemeTokens>();
  final scheme = theme.colorScheme;
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    color: tokens?.bg2 ?? scheme.surfaceContainerHigh,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(DesktopThemeTokens.menuRadius),
      side: theme.brightness == Brightness.dark
          ? const BorderSide(color: Color(0x14FFFFFF))
          : BorderSide(
              color:
                  tokens?.text3.withValues(alpha: 0.3) ?? scheme.outlineVariant,
            ),
    ),
    elevation: theme.brightness == Brightness.dark ? 0 : 8,
    items: items,
  );
}

/// Wraps [child] so a right-click opens [menuBuilder] at the pointer.
class DesktopContextMenuRegion<T> extends StatelessWidget {
  const DesktopContextMenuRegion({
    super.key,
    required this.menuBuilder,
    required this.child,
  });

  final List<PopupMenuEntry<T>> Function() menuBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: (details) {
        showDesktopMenu<T>(
          context: context,
          position: details.globalPosition,
          items: menuBuilder(),
        );
      },
      child: child,
    );
  }
}
