import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/design/app_palette.dart';
import 'package:my_website/src/core/design/app_surfaces.dart';

void main() {
  testWidgets('context.palette returns the palette registered on the theme', (tester) async {
    late AppPalette seen;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppSurfaces(AppPalette.dark)]),
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.canvas, AppPalette.dark.canvas);
  });

  testWidgets('context.palette falls back to light when no extension is registered', (tester) async {
    late AppPalette seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.canvas, AppPalette.light.canvas);
  });

  test('lerp interpolates the wrapped palette', () {
    const a = AppSurfaces(AppPalette.light);
    const b = AppSurfaces(AppPalette.dark);
    final mid = a.lerp(b, 1) as AppSurfaces;
    expect(mid.palette.canvas, AppPalette.dark.canvas);
  });
}
