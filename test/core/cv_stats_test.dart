import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/cv_stats.dart';
import 'package:my_website/src/models/cv.dart';

CV _cv({
  int? yearsExperience,
  List<Experience> experience = const [],
  List<Project> projects = const [],
  List<String> skills = const [],
}) =>
    CV(
      name: 'N',
      title: 'T',
      email: 'e',
      phone: 'p',
      location: 'l',
      linkedin: 'li',
      github: 'gh',
      summary: 's',
      yearsExperience: yearsExperience,
      education: Education(degree: 'd', university: 'u', period: 'p', location: 'l'),
      skills: skills,
      experience: experience,
      projects: projects,
      links: Links(appStoreExamples: const [], playStoreExamples: const []),
    );

Experience _exp(String period) =>
    Experience(company: 'c', role: 'r', period: period, location: 'l', highlights: const []);

Project _project(List<String> stores) => Project(
      name: 'p',
      period: '01/2024',
      description: 'd',
      technologies: const [],
      stores: stores,
    );

void main() {
  test('years falls back to the earliest experience start year', () {
    final stats = CvStats.from(
      _cv(experience: [_exp('02/2025 - Present'), _exp('03/2022 - 02/2025')]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.years, 4);
  });

  test('yearsExperience overrides the computed value', () {
    final stats = CvStats.from(
      _cv(yearsExperience: 5, experience: [_exp('03/2022 - 02/2025')]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.years, 5);
  });

  test('years is zero when there is no experience and no override', () {
    expect(CvStats.from(_cv(), now: DateTime(2026, 8, 26)).years, 0);
  });

  test('counts projects and distinct store hosts', () {
    final stats = CvStats.from(
      _cv(projects: [
        _project(const [
          'https://apps.apple.com/eg/app/a/id1',
          'https://play.google.com/store/apps/details?id=a',
          'https://appgallery.huawei.com/app/C1',
          'https://apps.microsoft.com/detail/x',
        ]),
        _project(const ['https://apps.apple.com/eg/app/b/id2']),
      ]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.projects, 2);
    expect(stats.stores, 4);
  });

  test('ignores unparseable store urls', () {
    final stats = CvStats.from(
      _cv(projects: [_project(const ['', 'not a url'])]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.stores, 0);
  });

  test('technologies counts the skill list', () {
    expect(CvStats.from(_cv(skills: const ['a', 'b', 'c'])).technologies, 3);
  });
}
