import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cv.dart';

class CVProvider extends ChangeNotifier {
  CV? _cv;

  CV? get cv => _cv;
  bool get isLoaded => _cv != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final override = prefs.getString('cv_override_json');
      if (override != null && override.trim().isNotEmpty) {
        await loadFromString(override);
        return;
      }
      final jsonStr = await rootBundle.loadString('assets/data/cv.json');
      await loadFromString(jsonStr);
    } catch (e) {
      debugPrint('Failed to load CV json: $e');
    }
  }

  Future<void> loadFromString(String jsonStr) async {
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    _cv = CV.fromJson(map);
    notifyListeners();
  }

  // Update methods for all CV fields
  Future<void> updateField(String field, dynamic value) async {
    if (_cv == null) return;

    final currentJson = _cv!.toJson();
    currentJson[field] = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cv_override_json', json.encode(currentJson));

    _cv = CV.fromJson(currentJson);
    notifyListeners();
  }

  Future<void> updateEducation(Map<String, dynamic> education) async {
    await updateField('education', education);
  }

  Future<void> updateSkills(List<String> skills) async {
    await updateField('skills', skills);
  }

  Future<void> addSkill(String skill) async {
    if (_cv == null) return;
    final skills = List<String>.from(_cv!.skills);
    if (!skills.contains(skill)) {
      skills.add(skill);
      await updateSkills(skills);
    }
  }

  Future<void> removeSkill(String skill) async {
    if (_cv == null) return;
    final skills = List<String>.from(_cv!.skills);
    skills.remove(skill);
    await updateSkills(skills);
  }

  Future<void> updateExperience(int index, Map<String, dynamic> experience) async {
    if (_cv == null || index >= _cv!.experience.length) return;

    final experiences = _cv!.experience.map((e) => e.toJson()).toList();
    experiences[index] = experience;
    await updateField('experience', experiences);
  }

  Future<void> updateProject(int index, Map<String, dynamic> project) async {
    if (_cv == null || index >= _cv!.projects.length) return;

    final projects = _cv!.projects.map((p) => p.toJson()).toList();
    projects[index] = project;
    await updateField('projects', projects);
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cv_override_json');

    final jsonStr = await rootBundle.loadString('assets/data/cv.json');
    await loadFromString(jsonStr);
  }
}
