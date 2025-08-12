import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/pages/home_page.dart';
import 'package:my_website/src/state/cv_provider.dart';

const _sample = '{"name":"John Doe","title":"Senior Mobile Engineer","email":"a@b.c","phone":"123","location":"X","linkedin":"L","github":"G","summary":"Summary.","education":{"degree":"BSc","university":"Uni","period":"1-2","location":"X"},"skills":["Flutter"],"experience":[],"projects":[],"links":{}}';

void main() {
  testWidgets('Hero renders name and title from JSON', (tester) async {
    final provider = CVProvider();
    await provider.loadFromString(_sample);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Senior Mobile Engineer'), findsOneWidget);
  });
}
