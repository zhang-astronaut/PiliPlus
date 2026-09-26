import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/utils/miuix_theme_bridge.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('themeDataFromMiuix', () {
    test('maps light miuix colors into Material ColorScheme', () {
      final miuix = MiuixThemeData.light();
      final theme = themeDataFromMiuix(miuix);

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, miuix.colors.primary);
      expect(theme.colorScheme.onSurface, miuix.colors.onSurface);
      expect(theme.colorScheme.surface, miuix.colors.surface);
      expect(theme.scaffoldBackgroundColor, miuix.colors.background);
      // Inverse pair follows Material semantics (light theme inverse is dark).
      expect(theme.colorScheme.inverseSurface, miuix.colors.onSurface);
      expect(theme.colorScheme.onInverseSurface, miuix.colors.surfaceContainer);
    });

    test('maps dark miuix colors into Material ColorScheme', () {
      final miuix = MiuixThemeData.dark();
      final theme = themeDataFromMiuix(miuix);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, miuix.colors.primary);
      expect(theme.colorScheme.inverseSurface, miuix.colors.surfaceContainer);
    });
  });
}
