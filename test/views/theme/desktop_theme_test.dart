import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _desktopTheme(Brightness brightness) {
  final scheme =
      (brightness == Brightness.dark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .eclipseDesktop
          .eclipseDesktopPrimary;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
  ).withDesktopTheme(brightness);
}

void main() {
  group('DesktopThemeTokens', () {
    test('dark tokens match the §1 spec hex values', () {
      const tokens = DesktopThemeTokens.dark;
      expect(tokens.bg0, const Color(0xFF1E1E30));
      expect(tokens.bg1, const Color(0xFF262640));
      expect(tokens.bg2, const Color(0xFF2D2D48));
      expect(tokens.bg3, const Color(0xFF35354F));
      expect(tokens.accent, const Color(0xFF9F51E3));
      expect(tokens.accentHover, const Color(0xFFAC63E9));
      expect(tokens.accentPressed, const Color(0xFF8B3FD4));
      expect(tokens.accentSoft, const Color(0x249F51E3));
      expect(tokens.text1, const Color(0xFFF1F1F8));
      expect(tokens.text2, const Color(0xFFA9A9C2));
      expect(tokens.text3, const Color(0xFF6F6F89));
      expect(tokens.success, const Color(0xFF34D399));
      expect(tokens.warning, const Color(0xFFFBBF24));
      expect(tokens.danger, const Color(0xFFF87171));
      expect(tokens.switchOff, const Color(0xFF63636F));
    });

    test('group title is purple 15px w700', () {
      final style = DesktopThemeTokens.dark.groupTitleStyle;
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, const Color(0xFF9F51E3));
    });

    test('light accent and semantic colors match the §1 spec', () {
      const tokens = DesktopThemeTokens.light;
      expect(tokens.accent, const Color(0xFF7C3AED));
      expect(tokens.success, const Color(0xFF047857));
      expect(tokens.warning, const Color(0xFFB45309));
      expect(tokens.danger, const Color(0xFFDC2626));
      expect(tokens.text3, const Color(0xFF8E8E9E));
    });

    test('copyWith and lerp round-trip', () {
      const tokens = DesktopThemeTokens.dark;
      expect(tokens.copyWith().accent, tokens.accent);
      expect(tokens.copyWith().bg0, tokens.bg0);
      expect(
        tokens.copyWith(accent: const Color(0xFF000000)).accent,
        const Color(0xFF000000),
      );
      final lerped = tokens.lerp(DesktopThemeTokens.light, 1);
      expect(lerped.accent, DesktopThemeTokens.light.accent);
      expect(tokens.lerp(null, 0.5), tokens);
    });
  });

  group('desktop color scheme', () {
    test('dark surfaces follow the bg0-bg3 ramp', () {
      final scheme = const ColorScheme.dark().eclipseDesktop;
      expect(scheme.surface, const Color(0xFF1E1E30));
      expect(scheme.surfaceContainer, const Color(0xFF262640));
      expect(scheme.surfaceContainerHigh, const Color(0xFF2D2D48));
      expect(scheme.surfaceContainerHighest, const Color(0xFF35354F));
      expect(scheme.onSurface, const Color(0xFFF1F1F8));
      expect(scheme.onSurfaceVariant, const Color(0xFFA9A9C2));
      expect(scheme.error, const Color(0xFFF87171));
    });

    test('desktop primary is the §1 accent when eclipse default', () {
      final dark =
          const ColorScheme.dark().eclipseDesktop.eclipseDesktopPrimary;
      expect(dark.primary, const Color(0xFF9F51E3));
      expect(dark.onPrimary, Colors.white);
      final light =
          const ColorScheme.light().eclipseDesktop.eclipseDesktopPrimary;
      expect(light.primary, const Color(0xFF7C3AED));
      expect(light.error, const Color(0xFFDC2626));
    });
  });

  group('withDesktopTheme', () {
    test('carries the tokens extension and §1 control rules', () {
      final theme = _desktopTheme(Brightness.dark);
      final tokens = theme.extension<DesktopThemeTokens>()!;
      expect(tokens.accent, const Color(0xFF9F51E3));

      final trackColor = theme.switchTheme.trackColor!;
      expect(
        trackColor.resolve({WidgetState.selected}),
        const Color(0xFF9F51E3),
      );
      expect(trackColor.resolve({}), const Color(0xFF63636F));
    });

    test('applies the §1 corner radii', () {
      final theme = _desktopTheme(Brightness.dark);
      BorderRadius radiusOf(ShapeBorder? shape) =>
          (shape as RoundedSuperellipseBorder).borderRadius as BorderRadius;
      expect(
        radiusOf(theme.cardTheme.shape).topLeft.x,
        DesktopThemeTokens.cardRadius,
      );
      expect(
        radiusOf(theme.dialogTheme.shape).topLeft.x,
        DesktopThemeTokens.dialogRadius,
      );
      expect(
        radiusOf(theme.popupMenuTheme.shape).topLeft.x,
        DesktopThemeTokens.menuRadius,
      );
    });
  });

  group('EclipseSection group title', () {
    Future<void> pumpSection(WidgetTester tester, {ThemeData? theme}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: EclipseSection(title: 'Group', children: [Text('row')]),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('uses the purple token style on the desktop theme', (
      tester,
    ) async {
      await pumpSection(tester, theme: _desktopTheme(Brightness.dark));
      final text = tester.widget<Text>(find.text('Group'));
      expect(text.style?.color, const Color(0xFF9F51E3));
      expect(text.style?.fontSize, 15);
      expect(text.style?.fontWeight, FontWeight.w700);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the legacy style without the desktop extension', (
      tester,
    ) async {
      await pumpSection(tester);
      final text = tester.widget<Text>(find.text('Group'));
      expect(text.style?.color, isNot(const Color(0xFF9F51E3)));
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(tester.takeException(), isNull);
    });
  });
}
