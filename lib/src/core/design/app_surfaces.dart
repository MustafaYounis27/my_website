import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Carries the active [AppPalette] on [ThemeData] so widgets can read design
/// tokens without importing the theme builder.
@immutable
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  final AppPalette palette;

  const AppSurfaces(this.palette);

  @override
  AppSurfaces copyWith({AppPalette? palette}) => AppSurfaces(palette ?? this.palette);

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(AppPalette.lerp(palette, other.palette, t));
  }
}

extension AppPaletteContext on BuildContext {
  /// The palette for the current theme. Falls back to light so widget tests
  /// that build a bare [MaterialApp] still render.
  AppPalette get palette =>
      Theme.of(this).extension<AppSurfaces>()?.palette ?? AppPalette.light;
}
