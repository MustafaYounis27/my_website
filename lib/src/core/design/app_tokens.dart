import 'package:flutter/animation.dart';

/// Spacing scale. Every gap and padding in the app comes from here.
abstract final class AppSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Vertical gap between top-level page sections on desktop.
  static const double section = 96;

  /// Vertical gap between top-level page sections below 600px.
  static const double sectionMobile = 64;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Durations and curves. Motion that is not listed here does not belong.
abstract final class AppMotion {
  static const Duration stagger = Duration(milliseconds: 60);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);

  /// Cross-fade between light and dark.
  static const Duration theme = Duration(milliseconds: 400);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
}
