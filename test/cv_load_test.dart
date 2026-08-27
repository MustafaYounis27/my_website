import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/models/cv.dart';

void main() {
  test('CV loads from JSON', () {
    const jsonStr = '{"name":"A","title":"B","email":"e","phone":"p","location":"l","linkedin":"li","github":"gh","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["x"],"experience":[],"projects":[],"links":{}}';
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    final cv = CV.fromJson(map);
    expect(cv.name, 'A');
    expect(cv.title, 'B');
    expect(cv.education.degree, 'd');
    expect(cv.skills, ['x']);
  });

  test('yearsExperience is optional and round-trips', () {
    const withField =
        '{"name":"A","title":"B","email":"e","phone":"p","location":"l","linkedin":"li","github":"gh","summary":"s","yearsExperience":5,"education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["x"],"experience":[],"projects":[],"links":{}}';
    final cv = CV.fromJson(json.decode(withField) as Map<String, dynamic>);
    expect(cv.yearsExperience, 5);
    expect(cv.toJson()['yearsExperience'], 5);

    const withoutField =
        '{"name":"A","title":"B","email":"e","phone":"p","location":"l","linkedin":"li","github":"gh","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["x"],"experience":[],"projects":[],"links":{}}';
    final bare = CV.fromJson(json.decode(withoutField) as Map<String, dynamic>);
    expect(bare.yearsExperience, isNull);
  });
}
