import 'package:material_ui/material_ui.dart';

abstract final class EclipsePalette {
  static const Color darkBackground = Color(0xFF15151F);
  static const Color darkLowest = Color(0xFF0F0F17);
  static const Color darkCard = Color(0xFF1F1F2B);
  static const Color darkCardHigh = Color(0xFF272732);
  static const Color darkCardHighest = Color(0xFF30303F);
  static const Color darkOnSurface = Color(0xFFECECF1);
  static const Color darkOnSurfaceVariant = Color(0xFFA9A9BC);

  static const Color lightBackground = Color(0xFFF7F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHigh = Color(0xFFEDEDF3);
  static const Color lightCardHighest = Color(0xFFE2E2EA);
  static const Color lightOnSurface = Color(0xFF191924);
  static const Color lightOnSurfaceVariant = Color(0xFF5C5C70);

  static const Color primary = Color(0xFF8B7CF6);
  static const Color primaryHighlight = Color(0xFFA78BFA);
  static const Color lightPrimary = Color(0xFF7C6CF0);
  static const Color darkPrimaryContainer = Color(0xFF3F3670);
  static const Color darkOnPrimaryContainer = Color(0xFFE3DBFF);
  static const Color lightPrimaryContainer = Color(0xFFE4E0FF);
  static const Color lightOnPrimaryContainer = Color(0xFF2A2370);

  static const Color success = Color(0xFF6BCB8E);
  static const Color warning = Color(0xFFE7C05B);
  static const Color error = Color(0xFFD77F7F);
}

extension EclipseThemeExtension on ThemeData {
  ThemeData get eclipse {
    final scheme = colorScheme.eclipse;
    return copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme.eclipse,
    );
  }
}

extension EclipseSchemeExtension on ColorScheme {
  ColorScheme get eclipse {
    return switch (brightness) {
      Brightness.dark => copyWith(
        surface: EclipsePalette.darkBackground,
        surfaceDim: EclipsePalette.darkLowest,
        surfaceBright: EclipsePalette.darkCardHighest,
        surfaceContainerLowest: EclipsePalette.darkLowest,
        surfaceContainerLow: EclipsePalette.darkCard,
        surfaceContainer: EclipsePalette.darkCard,
        surfaceContainerHigh: EclipsePalette.darkCardHigh,
        surfaceContainerHighest: EclipsePalette.darkCardHighest,
        surfaceTint: Colors.transparent,
        onSurface: EclipsePalette.darkOnSurface,
        onSurfaceVariant: EclipsePalette.darkOnSurfaceVariant,
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
      ),
    };
  }

  ColorScheme get eclipsePrimary {
    return switch (brightness) {
      Brightness.dark => copyWith(
        primary: EclipsePalette.primary,
        onPrimary: Colors.white,
        primaryContainer: EclipsePalette.darkPrimaryContainer,
        onPrimaryContainer: EclipsePalette.darkOnPrimaryContainer,
      ),
      Brightness.light => copyWith(
        primary: EclipsePalette.lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: EclipsePalette.lightPrimaryContainer,
        onPrimaryContainer: EclipsePalette.lightOnPrimaryContainer,
      ),
    };
  }
}

extension EclipseTextThemeExtension on TextTheme {
  TextTheme get eclipse {
    return copyWith(
      titleLarge: titleLarge?.copyWith(fontSize: 17),
      titleMedium: titleMedium?.copyWith(fontSize: 17),
      titleSmall: titleSmall?.copyWith(fontSize: 15),
      bodyLarge: bodyLarge?.copyWith(fontSize: 15),
      bodyMedium: bodyMedium?.copyWith(fontSize: 13),
      bodySmall: bodySmall?.copyWith(fontSize: 12),
      labelLarge: labelLarge?.copyWith(fontSize: 15),
      labelMedium: labelMedium?.copyWith(fontSize: 13),
      labelSmall: labelSmall?.copyWith(fontSize: 12),
    );
  }
}
