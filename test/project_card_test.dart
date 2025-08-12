import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/models/cv.dart';
import 'package:my_website/src/widgets/project_card.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class _TestSvgBundle extends CachingAssetBundle {
  static const String _assetPath = 'assets/images/project_placeholder.svg';
  static const String _svg = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="9"><rect width="100%" height="100%" fill="#cccccc"/></svg>';

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith(_assetPath)) {
      final bytes = Uint8List.fromList(utf8.encode(_svg));
      return ByteData.view(bytes.buffer);
    }
    // Return empty data for other assets to avoid calling abstract super.load
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith(_assetPath)) {
      return _svg;
    }
    return '';
  }
}

void main() {
  testWidgets('Project card shows title and opens dialog', (tester) async {
    final project = Project(name: 'Proj', period: '2020', description: 'Desc', stores: const ['https://example.com']);
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _TestSvgBundle(),
        child: MaterialApp(
          home: Scaffold(body: ProjectCard(project: project)),
        ),
      ),
    );

    expect(find.text('Proj'), findsOneWidget);
    await tester.tap(find.byType(ProjectCard));
    await tester.pumpAndSettle();
    expect(find.text('Desc'), findsOneWidget);
  });
}
