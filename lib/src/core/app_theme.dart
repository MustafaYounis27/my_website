import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design/app_palette.dart';
import 'design/app_surfaces.dart';
import 'design/app_tokens.dart';

/// Builds both themes from an [AppPalette]. Nothing here hardcodes a colour —
/// change `app_palette.dart` and both themes follow.
abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.brand,
      onPrimary: p.onBrand,
      primaryContainer: p.brandSoft,
      onPrimaryContainer: p.brand,
      secondary: p.brandAlt,
      onSecondary: p.onBrand,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      outline: p.hairline,
      outlineVariant: p.hairline,
      error: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB3261E),
      onError: isDark ? const Color(0xFF0B0A18) : Colors.white,
      shadow: p.shadow,
    );

    TextStyle display(double size, FontWeight weight) =>
        GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: p.ink, letterSpacing: -0.5);

    final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: display(56, FontWeight.w800),
      displayMedium: display(44, FontWeight.w800),
      displaySmall: display(34, FontWeight.w700),
      headlineLarge: display(30, FontWeight.w700),
      headlineMedium: display(24, FontWeight.w700),
      headlineSmall: display(20, FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.65, color: p.inkMuted),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.6, color: p.inkMuted),
      bodySmall: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: p.inkSubtle),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: p.brand,
      ),
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm));
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md);

    return base.copyWith(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      textTheme: text,
      extensions: [AppSurfaces(p)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: DividerThemeData(color: p.hairline, space: 1, thickness: 1),
      iconTheme: IconThemeData(color: p.inkMuted),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.onBrand,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.brand,
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: p.hairline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.brand, textStyle: text.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceGlass : p.surface,
        hintStyle: text.bodyMedium?.copyWith(color: p.inkSubtle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.brand, width: 1.5),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
