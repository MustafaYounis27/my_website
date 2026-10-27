import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/pages/home_page.dart';
import 'package:my_website/src/pages/projects_page.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/state/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the real cv.json at common screen widths and fails on any layout
/// overflow, so a long name or a new project can't silently break a breakpoint.
const _widths = <double>[320, 360, 390, 414, 600, 768, 900, 1024, 1280, 1440];

Future<void> _pumpPage(WidgetTester tester, double width, Widget page, {bool dark = false}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final cv = CVProvider();
  await cv.loadFromString(File('assets/data/cv.json').readAsStringSync());

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CVProvider>.value(value: cv),
        ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls the page top to bottom so lazily built sections lay out too.
Future<void> _scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 40; i++) {
    await tester.drag(scrollable, const Offset(0, -600), warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Real metrics: the default test font draws every glyph as a wide square,
    // which reports overflows that never happen in a browser.
    for (final family in ['Inter', 'Poppins']) {
      final loader = FontLoader(family);
      for (final file in Directory('assets/fonts').listSync().whereType<File>()) {
        if (file.path.contains(family)) {
          loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
        }
      }
      await loader.load();
    }
    // Icons render via MaterialIcons; load it so icon widths are real too.
    final icons = File('${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
    }
  });

  for (final width in _widths) {
    testWidgets('home page has no overflow at ${width.toInt()}px', (tester) async {
      await _pumpPage(tester, width, const HomePage());
      await _scrollThrough(tester);
    });

    testWidgets('projects page has no overflow at ${width.toInt()}px', (tester) async {
      await _pumpPage(tester, width, const ProjectsPage(), dark: true);
      await _scrollThrough(tester);
    });
  }
}
