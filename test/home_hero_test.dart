import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/pages/home_page.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/state/theme_provider.dart';

const _sample = '{"name":"John Doe","title":"Senior Mobile Engineer","email":"a@b.c","phone":"123","location":"X","linkedin":"L","github":"G","summary":"Summary.","education":{"degree":"BSc","university":"Uni","period":"1-2","location":"X"},"skills":["Flutter"],"experience":[],"projects":[],"links":{}}';

void main() {
  testWidgets('Hero renders name and title from JSON', (tester) async {
    final cvProvider = CVProvider();
    await cvProvider.loadFromString(_sample);
    final themeProvider = ThemeProvider();

    // Use a wide surface so the AppBar nav doesn't overflow (default 800px is tight)
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CVProvider>.value(value: cvProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Senior Mobile Engineer'), findsOneWidget);
  });
}
