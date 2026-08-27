import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/design/app_palette.dart';

double _channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('light and dark palettes are distinct and complete', () {
    expect(AppPalette.light.brightness, Brightness.light);
    expect(AppPalette.dark.brightness, Brightness.dark);
    expect(AppPalette.light.canvas, isNot(AppPalette.dark.canvas));
    expect(AppPalette.light.gradient.length, 2);
    expect(AppPalette.dark.gradient.length, 2);
  });

  test('body ink clears WCAG AA against its own canvas in both themes', () {
    expect(_contrast(AppPalette.light.ink, AppPalette.light.canvas), greaterThan(4.5));
    expect(_contrast(AppPalette.dark.ink, AppPalette.dark.canvas), greaterThan(4.5));
  });

  test('brand accent clears WCAG AA against its own canvas in both themes', () {
    expect(_contrast(AppPalette.light.brand, AppPalette.light.canvas), greaterThan(4.5));
    expect(_contrast(AppPalette.dark.brand, AppPalette.dark.canvas), greaterThan(4.5));
  });

  test('lerp at the endpoints returns the endpoints', () {
    final a = AppPalette.lerp(AppPalette.light, AppPalette.dark, 0);
    final b = AppPalette.lerp(AppPalette.light, AppPalette.dark, 1);
    expect(a.canvas, AppPalette.light.canvas);
    expect(b.canvas, AppPalette.dark.canvas);
  });
}
