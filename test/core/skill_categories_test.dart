import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/skill_categories.dart';

void main() {
  test('groups known skills into their category', () {
    final groups = SkillCategories.group(const ['Flutter', 'Firebase', 'CI/CD']);
    expect(groups[0].title, 'Mobile');
    expect(groups[0].skills, ['Flutter']);
    expect(groups[1].title, 'Backend & Data');
    expect(groups[1].skills, ['Firebase']);
    expect(groups[2].title, 'Delivery & Practices');
    expect(groups[2].skills, ['CI/CD']);
  });

  test('unknown skills fall into Delivery & Practices, never dropped', () {
    final groups = SkillCategories.group(const ['Flutter', 'Underwater Basket Weaving']);
    final all = groups.expand((g) => g.skills).toList();
    expect(all, containsAll(['Flutter', 'Underwater Basket Weaving']));
    expect(all.length, 2);
  });

  test('every skill in the real CV list survives categorisation', () {
    const skills = [
      'Flutter', 'Android', 'Dart', 'Java', 'Kotlin', 'Python', 'Git',
      'Firebase', 'OOP', 'CI/CD', 'Design Patterns', 'SOLID', 'Team Management',
    ];
    final all = SkillCategories.group(skills).expand((g) => g.skills).toList();
    expect(all.length, skills.length);
    expect(all.toSet(), skills.toSet());
  });

  test('empty categories are omitted', () {
    final groups = SkillCategories.group(const ['Flutter']);
    expect(groups.length, 1);
    expect(groups.single.title, 'Mobile');
  });

  test('matching is case-insensitive', () {
    final groups = SkillCategories.group(const ['flutter']);
    expect(groups.single.title, 'Mobile');
  });
}
