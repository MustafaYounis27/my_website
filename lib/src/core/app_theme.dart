import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF6366F1); // Modern indigo
  static const _accentColor = Color(0xFF8B5CF6); // Purple accent
  
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _accentColor,
      surface: Colors.grey[50],
      background: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.6),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: _accentColor,
      surface: const Color(0xFF1A1B26),
      background: const Color(0xFF0F0F1E),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.6),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFF0F0F1E).withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Color(0xFF1A1B26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
