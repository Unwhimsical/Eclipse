import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// §1 card: bg2 fill, 1px outlined edge (white 8% with a 10% top inner
/// highlight and 5% bottom edge on dark), radius 20, no shadow on dark.
/// Controls inside a card hover with white overlays, never solid fills.
///
/// The four-side border cannot carry a radius (Flutter asserts on
/// non-uniform [Border] + borderRadius), so the radius comes from an outer
/// [ClipRSuperellipse] while the border itself stays square.
class DesktopCard extends StatelessWidget {
  const DesktopCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final isDark = theme.brightness == Brightness.dark;
    final card = Container(
      margin: margin,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
        ),
        color: tokens?.bg2 ?? theme.colorScheme.surfaceContainerHigh,
        shadows: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: isDark
                ? DesktopThemeTokens.cardBorder
                : Border.all(
                    color:
                        tokens?.text3.withValues(alpha: 0.25) ??
                        const Color(0x40000000),
                  ),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
        ),
        child: card,
      ),
    );
  }
}
