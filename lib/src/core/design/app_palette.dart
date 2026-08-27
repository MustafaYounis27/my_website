import 'package:flutter/material.dart';

/// Every colour in the app, as data. Widgets read these through
/// `context.palette` (see `app_surfaces.dart`) and never hardcode a Color.
@immutable
class AppPalette {
  final Brightness brightness;

  /// Page background behind everything.
  final Color canvas;

  /// Top-left aurora glow.
  final Color auroraPrimary;

  /// Top-right aurora glow.
  final Color auroraSecondary;

  /// Opaque card background.
  final Color surface;

  /// Translucent card background, used with a blur.
  final Color surfaceGlass;

  /// 1px border on every card.
  final Color hairline;

  /// Primary text.
  final Color ink;

  /// Secondary text (body copy, highlights).
  final Color inkMuted;

  /// Tertiary text (labels, metadata).
  final Color inkSubtle;

  /// Accent for text and icons — AA-safe on [canvas].
  final Color brand;

  /// Secondary accent.
  final Color brandAlt;

  /// Accent at low alpha, for chip and icon backgrounds.
  final Color brandSoft;

  /// Text/icon colour on top of a brand-filled surface.
  final Color onBrand;

  /// The two stops of the signature gradient, 135°.
  final List<Color> gradient;

  /// Card shadow colour.
  final Color shadow;

  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.auroraPrimary,
    required this.auroraSecondary,
    required this.surface,
    required this.surfaceGlass,
    required this.hairline,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.brand,
    required this.brandAlt,
    required this.brandSoft,
    required this.onBrand,
    required this.gradient,
    required this.shadow,
  });

  /// Indigo Aurora.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFFBFBFE),
    auroraPrimary: Color(0x426366F1),
    auroraSecondary: Color(0x388B5CF6),
    surface: Color(0xFFFFFFFF),
    surfaceGlass: Color(0xB8FFFFFF),
    hairline: Color(0x140F0F1E),
    ink: Color(0xFF14142B),
    inkMuted: Color(0xFF5A5A75),
    inkSubtle: Color(0xFF6E6E88),
    brand: Color(0xFF4F46E5),
    brandAlt: Color(0xFF8B32D6),
    brandSoft: Color(0x1A6366F1),
    onBrand: Color(0xFFFFFFFF),
    gradient: [Color(0xFF6366F1), Color(0xFFA855F7)],
    shadow: Color(0x1714142B),
  );

  /// Indigo Night.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0B0A18),
    auroraPrimary: Color(0x4D6366F1),
    auroraSecondary: Color(0x3DA855F7),
    surface: Color(0xFF141327),
    surfaceGlass: Color(0x0EFFFFFF),
    hairline: Color(0x1AFFFFFF),
    ink: Color(0xFFF2F1FA),
    inkMuted: Color(0xFFA9A7C6),
    inkSubtle: Color(0xFF9391B4),
    brand: Color(0xFFA5B4FC),
    brandAlt: Color(0xFFC084FC),
    brandSoft: Color(0x24818CF8),
    onBrand: Color(0xFF0B0A18),
    gradient: [Color(0xFFA5B4FC), Color(0xFFC084FC)],
    shadow: Color(0x80000000),
  );

  /// Interpolates every colour so the theme toggle cross-fades smoothly.
  static AppPalette lerp(AppPalette a, AppPalette b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppPalette(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      canvas: c(a.canvas, b.canvas),
      auroraPrimary: c(a.auroraPrimary, b.auroraPrimary),
      auroraSecondary: c(a.auroraSecondary, b.auroraSecondary),
      surface: c(a.surface, b.surface),
      surfaceGlass: c(a.surfaceGlass, b.surfaceGlass),
      hairline: c(a.hairline, b.hairline),
      ink: c(a.ink, b.ink),
      inkMuted: c(a.inkMuted, b.inkMuted),
      inkSubtle: c(a.inkSubtle, b.inkSubtle),
      brand: c(a.brand, b.brand),
      brandAlt: c(a.brandAlt, b.brandAlt),
      brandSoft: c(a.brandSoft, b.brandSoft),
      onBrand: c(a.onBrand, b.onBrand),
      gradient: [c(a.gradient[0], b.gradient[0]), c(a.gradient[1], b.gradient[1])],
      shadow: c(a.shadow, b.shadow),
    );
  }
}
