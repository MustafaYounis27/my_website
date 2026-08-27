import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/widgets/common/section_shell.dart';

void main() {
  testWidgets('SectionShell renders eyebrow, title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SectionShell(
              index: '01',
              label: 'TEST',
              title: 'Title',
              subtitle: 'Subtitle',
              child: const Text('body'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('01 — TEST'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });
}
