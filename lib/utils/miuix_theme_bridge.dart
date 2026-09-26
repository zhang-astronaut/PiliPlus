import 'package:flutter_miuix/miuix.dart';
import 'package:material_ui/material_ui.dart';

/// Map HyperOS / miuix semantic colors onto Material [ThemeData]
/// so unmigrated Material widgets stay coordinated with Miuix.
ThemeData themeDataFromMiuix(
  MiuixThemeData theme, {
  String? fontFamily,
  FontWeight fontWeight = FontWeight.normal,
}) {
  final colors = theme.colors;

  // Inverse pair must follow Material semantics: light theme inverseSurface is dark.
  final isDark = theme.brightness == Brightness.dark;
  final inverseSurface = isDark ? colors.surfaceContainer : colors.onSurface;
  final onInverseSurface = isDark ? colors.onSurface : colors.surfaceContainer;

  TextTheme? textTheme;
  if (fontWeight != FontWeight.normal) {
    final textStyle = TextStyle(fontWeight: fontWeight);
    textTheme = TextTheme(
      displayLarge: textStyle,
      displayMedium: textStyle,
      displaySmall: textStyle,
      headlineLarge: textStyle,
      headlineMedium: textStyle,
      headlineSmall: textStyle,
      titleLarge: textStyle,
      titleMedium: textStyle,
      titleSmall: textStyle,
      bodyLarge: textStyle,
      bodyMedium: textStyle,
      bodySmall: textStyle,
      labelLarge: textStyle,
      labelMedium: textStyle,
      labelSmall: textStyle,
    );
  }

  final colorScheme = ColorScheme(
    brightness: theme.brightness,
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    primaryContainer: colors.primaryContainer,
    onPrimaryContainer: colors.onPrimaryContainer,
    secondary: colors.secondary,
    onSecondary: colors.onSecondary,
    secondaryContainer: colors.secondaryContainer,
    onSecondaryContainer: colors.onSecondaryContainer,
    tertiary: colors.tertiaryContainer,
    onTertiary: colors.onTertiaryContainer,
    tertiaryContainer: colors.tertiaryContainer,
    onTertiaryContainer: colors.onTertiaryContainer,
    error: colors.error,
    onError: colors.onError,
    errorContainer: colors.errorContainer,
    onErrorContainer: colors.onErrorContainer,
    surface: colors.surface,
    onSurface: colors.onSurface,
    onSurfaceVariant: colors.onSurfaceVariantSummary,
    outline: colors.outline,
    outlineVariant: colors.dividerLine,
    shadow: colors.windowDimming,
    scrim: colors.windowDimming,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: colors.primaryVariant,
    surfaceContainerLowest: colors.background,
    surfaceContainerLow: colors.surface,
    surfaceContainer: colors.surfaceContainer,
    surfaceContainerHigh: colors.surfaceContainerHigh,
    surfaceContainerHighest: colors.surfaceContainerHighest,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: colors.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surface,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: colors.onSurface,
      ),
    ),
    dividerColor: colors.dividerLine,
    splashFactory: InkSparkle.splashFactory,
  );
}
