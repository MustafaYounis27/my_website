import 'package:flutter/material.dart';

/// One rendered skill group.
class SkillGroup {
  final String title;
  final IconData icon;
  final List<String> skills;

  const SkillGroup({required this.title, required this.icon, required this.skills});
}

/// Splits the flat `cv.skills` list into three display groups.
abstract final class SkillCategories {
  static const _mobile = {
    'flutter', 'dart', 'android', 'ios', 'kotlin', 'java', 'swift', 'jetpack compose',
  };

  static const _backend = {
    'firebase', 'sql', 'python', 'rest', 'rest api', 'graphql', 'socket io', 'soket io',
    'sockets', 'node', 'c#', 'supabase',
  };

  static List<SkillGroup> group(List<String> skills) {
    final mobile = <String>[];
    final backend = <String>[];
    final delivery = <String>[];

    for (final skill in skills) {
      final key = skill.toLowerCase().trim();
      if (_mobile.contains(key)) {
        mobile.add(skill);
      } else if (_backend.contains(key)) {
        backend.add(skill);
      } else {
        delivery.add(skill);
      }
    }

    return [
      if (mobile.isNotEmpty)
        SkillGroup(title: 'Mobile', icon: Icons.phone_iphone_rounded, skills: mobile),
      if (backend.isNotEmpty)
        SkillGroup(title: 'Backend & Data', icon: Icons.cloud_outlined, skills: backend),
      if (delivery.isNotEmpty)
        SkillGroup(title: 'Delivery & Practices', icon: Icons.rocket_launch_outlined, skills: delivery),
    ];
  }
}
