import '../models/cv.dart';

/// The four numbers shown under the hero. Every one is derived from the CV —
/// nothing here is hardcoded.
class CvStats {
  final int years;
  final int projects;
  final int stores;
  final int technologies;

  const CvStats({
    required this.years,
    required this.projects,
    required this.stores,
    required this.technologies,
  });

  factory CvStats.from(CV cv, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return CvStats(
      years: cv.yearsExperience ?? _computedYears(cv, today),
      projects: cv.projects.length,
      stores: _distinctStoreHosts(cv),
      technologies: cv.skills.length,
    );
  }

  /// Whole years since the earliest role started. Returns 0 when unknown.
  static int _computedYears(CV cv, DateTime today) {
    DateTime? earliest;
    for (final exp in cv.experience) {
      final start = _parseMonthYear(exp.period.split('-').first.trim());
      if (start == null) continue;
      if (earliest == null || start.isBefore(earliest)) earliest = start;
    }
    if (earliest == null) return 0;
    var years = today.year - earliest.year;
    if (today.month < earliest.month) years -= 1;
    return years < 0 ? 0 : years;
  }

  /// Parses `MM/yyyy`. Returns null for anything else, including "Present".
  static DateTime? _parseMonthYear(String value) {
    final match = RegExp(r'^(\d{1,2})/(\d{4})$').firstMatch(value);
    if (match == null) return null;
    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) return null;
    return DateTime(int.parse(match.group(2)!), month);
  }

  /// Distinct hosts across every project's store links.
  static int _distinctStoreHosts(CV cv) {
    final hosts = <String>{};
    for (final project in cv.projects) {
      for (final url in project.stores) {
        final host = Uri.tryParse(url)?.host;
        if (host != null && host.isNotEmpty) hosts.add(host.toLowerCase());
      }
    }
    return hosts.length;
  }
}
