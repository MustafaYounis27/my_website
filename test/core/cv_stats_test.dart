import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/cv_stats.dart';
import 'package:my_website/src/models/cv.dart';

CV _cv({
  int? yearsExperience,
  String? usersReached,
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
      usersReached: usersReached,
      education: Education(degree: 'd', university: 'u', period: 'p', location: 'l'),
      skills: skills,
      experience: experience,
      projects: projects,
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

  test('counts shipped apps and distinct store hosts', () {
    final stats = CvStats.from(
      _cv(projects: [
        _project(const [
          'https://apps.apple.com/eg/app/a/id1',
          'https://play.google.com/store/apps/details?id=a',
          'https://appgallery.huawei.com/app/C1',
          'https://apps.microsoft.com/detail/x',
        ]),
        _project(const ['https://apps.apple.com/eg/app/b/id2']),
        _project(const []),
      ]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.appsShipped, 2);
    expect(stats.stores, 4);
  });

  test('ignores unparseable store urls', () {
    final stats = CvStats.from(
      _cv(projects: [_project(const ['', 'not a url'])]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.stores, 0);
  });

  test('usersReached passes through and blank hides it', () {
    expect(CvStats.from(_cv(usersReached: '250K+')).usersReached, '250K+');
    expect(CvStats.from(_cv(usersReached: '  ')).usersReached, isNull);
    expect(CvStats.from(_cv()).usersReached, isNull);
  });
}
