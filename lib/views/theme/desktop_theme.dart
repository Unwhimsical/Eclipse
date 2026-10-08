import 'package:fl_clash/views/theme/eclipse_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Desktop-only design tokens from the desktop UI redesign (§1).
/// Landed as a [ThemeExtension] so desktop pages read them through
/// `Theme.of(context).extension<DesktopThemeTokens>()`; the mobile theme
/// never carries this extension and is untouched.
class DesktopThemeTokens extends ThemeExtension<DesktopThemeTokens> {
  const DesktopThemeTokens({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.accent,
    required this.accentHover,
    required this.accentPressed,
    required this.accentSoft,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.success,
    required this.warning,
    required this.danger,
    required this.dangerHover,
    required this.switchOff,
    required this.groupTitleStyle,
    required this.pageTitleStyle,
  });

  static const DesktopThemeTokens dark = DesktopThemeTokens(
    bg0: Color(0xFF1E1E30),
    bg1: Color(0xFF262640),
    bg2: Color(0xFF2D2D48),
    bg3: Color(0xFF35354F),
    accent: Color(0xFF9F51E3),
    accentHover: Color(0xFFAC63E9),
    accentPressed: Color(0xFF8B3FD4),
    accentSoft: Color(0x249F51E3),
    text1: Color(0xFFF1F1F8),
    text2: Color(0xFFA9A9C2),
    text3: Color(0xFF6F6F89),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    dangerHover: Color(0xFFDC2626),
    switchOff: Color(0xFF63636F),
    groupTitleStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF9F51E3),
    ),
    pageTitleStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFFF1F1F8),
    ),
  );

  static const DesktopThemeTokens light = DesktopThemeTokens(
    bg0: EclipsePalette.lightBackground,
    bg1: EclipsePalette.lightCardHigh,
    bg2: EclipsePalette.lightCard,
    bg3: EclipsePalette.lightCardHighest,
    accent: Color(0xFF7C3AED),
    accentHover: Color(0xFF8B5CF6),
    accentPressed: Color(0xFF6D28D9),
    accentSoft: Color(0x247C3AED),
    text1: EclipsePalette.lightOnSurface,
    text2: EclipsePalette.lightOnSurfaceVariant,
    text3: Color(0xFF8E8E9E),
    success: Color(0xFF047857),
    warning: Color(0xFFB45309),
    danger: Color(0xFFDC2626),
    dangerHover: Color(0xFFB91C1C),
    switchOff: Color(0xFF63636F),
    groupTitleStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF7C3AED),
    ),
    pageTitleStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: EclipsePalette.lightOnSurface,
    ),
  );

  /// §1 card outline: 1px white 8%, with a white 10% top inner highlight
  /// and a white 5% bottom edge on dark.
  static const Border cardBorder = Border(
    top: BorderSide(color: Color(0x1AFFFFFF)),
    left: BorderSide(color: Color(0x14FFFFFF)),
    right: BorderSide(color: Color(0x14FFFFFF)),
    bottom: BorderSide(color: Color(0x0DFFFFFF)),
  );

  /// §1 hard rule: controls inside a card hover/press with white overlays,
  /// never solid bg1/bg3 fills.
  static const Color controlHoverOverlay = Color(0x0FFFFFFF);
  static const Color controlPressedOverlay = Color(0x14FFFFFF);

  static const double cardRadius = 20;
  static const double dialogRadius = 24;
  static const double buttonRadius = 12;
  static const double menuRadius = 12;

  static const String monoFontFamily = 'SF Mono';
  static const List<String> monoFontFamilyFallback = [
    'Cascadia Code',
    'Consolas',
    'monospace',
  ];

  static const List<FontFeature> kpiFontFeatures = [
    FontFeature.tabularFigures(),
  ];

  final Color bg0;
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color accent;
  final Color accentHover;
  final Color accentPressed;
  final Color accentSoft;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color success;
  final Color warning;
  final Color danger;
  final Color dangerHover;
  final Color switchOff;
  final TextStyle groupTitleStyle;
  final TextStyle pageTitleStyle;

  @override
  DesktopThemeTokens copyWith({
    Color? bg0,
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? accent,
    Color? accentHover,
    Color? accentPressed,
    Color? accentSoft,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? success,
    Color? warning,
    Color? danger,
    Color? dangerHover,
    Color? switchOff,
    TextStyle? groupTitleStyle,
    TextStyle? pageTitleStyle,
  }) {
    return DesktopThemeTokens(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentPressed: accentPressed ?? this.accentPressed,
      accentSoft: accentSoft ?? this.accentSoft,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      dangerHover: dangerHover ?? this.dangerHover,
      switchOff: switchOff ?? this.switchOff,
      groupTitleStyle: groupTitleStyle ?? this.groupTitleStyle,
      pageTitleStyle: pageTitleStyle ?? this.pageTitleStyle,
    );
  }

  @override
  DesktopThemeTokens lerp(ThemeExtension<DesktopThemeTokens>? other, double t) {
    if (other is! DesktopThemeTokens) return this;
    return DesktopThemeTokens(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerHover: Color.lerp(dangerHover, other.dangerHover, t)!,
      switchOff: Color.lerp(switchOff, other.switchOff, t)!,
      groupTitleStyle: TextStyle.lerp(
        groupTitleStyle,
        other.groupTitleStyle,
        t,
      )!,
      pageTitleStyle: TextStyle.lerp(pageTitleStyle, other.pageTitleStyle, t)!,
    );
  }
}

extension DesktopColorScheme on ColorScheme {
  /// Desktop surface ramp (§1): bg0 window, bg1 sidebar/top bars,
  /// bg2 cards, bg3 raised/hover. Light keeps the existing eclipse ramp;
  /// only the semantic colors move to the §1 values.
  ColorScheme get eclipseDesktop {
    return switch (brightness) {
      Brightness.dark => copyWith(
        surface: DesktopThemeTokens.dark.bg0,
        surfaceDim: DesktopThemeTokens.dark.bg0,
        surfaceBright: DesktopThemeTokens.dark.bg3,
        surfaceContainerLowest: DesktopThemeTokens.dark.bg0,
        surfaceContainerLow: DesktopThemeTokens.dark.bg1,
        surfaceContainer: DesktopThemeTokens.dark.bg1,
        surfaceContainerHigh: DesktopThemeTokens.dark.bg2,
        surfaceContainerHighest: DesktopThemeTokens.dark.bg3,
        surfaceTint: Colors.transparent,
        onSurface: DesktopThemeTokens.dark.text1,
        onSurfaceVariant: DesktopThemeTokens.dark.text2,
        error: DesktopThemeTokens.dark.danger,
        onError: Colors.white,
      ),
      Brightness.light => copyWith(
        surface: EclipsePalette.lightBackground,
        surfaceDim: EclipsePalette.lightCardHigh,
        surfaceBright: EclipsePalette.lightCard,
        surfaceContainerLowest: EclipsePalette.lightCard,
        surfaceContainerLow: EclipsePalette.lightCard,
        surfaceContainer: EclipsePalette.lightCard,
        surfaceContainerHigh: EclipsePalette.lightCardHigh,
        surfaceContainerHighest: EclipsePalette.lightCardHighest,
        surfaceTint: Colors.transparent,
        onSurface: EclipsePalette.lightOnSurface,
        onSurfaceVariant: EclipsePalette.lightOnSurfaceVariant,
        error: DesktopThemeTokens.light.danger,
        onError: Colors.white,
      ),
    };
  }

  /// The eclipse default primary on desktop is the §1 accent, not the
  /// mobile violet. Containers stay on the eclipse violet ramp.
  ColorScheme get eclipseDesktopPrimary {
    return switch (brightness) {
      Brightness.dark => copyWith(
        primary: DesktopThemeTokens.dark.accent,
        onPrimary: Colors.white,
        primaryContainer: EclipsePalette.darkPrimaryContainer,
        onPrimaryContainer: EclipsePalette.darkOnPrimaryContainer,
      ),
      Brightness.light => copyWith(
        primary: DesktopThemeTokens.light.accent,
        onPrimary: Colors.white,
        primaryContainer: EclipsePalette.lightPrimaryContainer,
        onPrimaryContainer: EclipsePalette.lightOnPrimaryContainer,
      ),
    };
  }
}

extension DesktopThemeData on ThemeData {
  /// Applies the desktop tokens, §1 control shapes and the switch track
  /// rule (on = solid accent, off = #63636F) on top of the repo shapes.
  ThemeData withDesktopTheme(Brightness brightness) {
    final tokens = brightness == Brightness.dark
        ? DesktopThemeTokens.dark
        : DesktopThemeTokens.light;
    final buttonShape = WidgetStatePropertyAll(
      RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(DesktopThemeTokens.buttonRadius),
      ),
    );
    return copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme.eclipse,
      extensions: [...extensions.values, tokens],
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.accent;
          return tokens.switchOff;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      cardTheme: cardTheme.copyWith(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.cardRadius),
        ),
      ),
      dialogTheme: dialogTheme.copyWith(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.dialogRadius),
        ),
      ),
      popupMenuTheme: popupMenuTheme.copyWith(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(DesktopThemeTokens.menuRadius),
        ),
      ),
      menuTheme: MenuThemeData(
        style: (menuTheme.style ?? const MenuStyle()).copyWith(
          shape: WidgetStatePropertyAll(
            RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(
                DesktopThemeTokens.menuRadius,
              ),
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: (filledButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: (outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (textButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: buttonShape,
        ),
      ),
    );
  }
}
