import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/core/design/app_palette.dart';
import 'package:my_website/src/core/design/app_surfaces.dart';

void main() {
  test('light theme carries the light palette and paints the light canvas', () {
    final theme = AppTheme.light;
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppSurfaces>()?.palette.canvas, AppPalette.light.canvas);
    expect(theme.scaffoldBackgroundColor, AppPalette.light.canvas);
  });

  test('dark theme carries the dark palette and paints the dark canvas', () {
    final theme = AppTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppSurfaces>()?.palette.canvas, AppPalette.dark.canvas);
    expect(theme.scaffoldBackgroundColor, AppPalette.dark.canvas);
  });

  test('both themes keep the app bar transparent so the aurora shows through', () {
    expect(AppTheme.light.appBarTheme.backgroundColor, Colors.transparent);
    expect(AppTheme.dark.appBarTheme.backgroundColor, Colors.transparent);
    expect(AppTheme.light.appBarTheme.scrolledUnderElevation, 0);
    expect(AppTheme.dark.appBarTheme.scrolledUnderElevation, 0);
  });

  test('colour scheme primary matches the palette brand in both themes', () {
    expect(AppTheme.light.colorScheme.primary, AppPalette.light.brand);
    expect(AppTheme.dark.colorScheme.primary, AppPalette.dark.brand);
    expect(AppTheme.dark.colorScheme.onPrimary, AppPalette.dark.onBrand);
  });
}
