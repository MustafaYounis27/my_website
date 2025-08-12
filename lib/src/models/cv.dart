class CV {
  final String name;
  final String title;
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String github;
  final String summary;
  final String? profileImage; // Can be a URL or base64 string
  final Education education;
  final List<String> skills;
  final List<Experience> experience;
  final List<Project> projects;
  final Links links;

  CV({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.github,
    required this.summary,
    this.profileImage,
    required this.education,
    required this.skills,
    required this.experience,
    required this.projects,
    required this.links,
  });

  factory CV.fromJson(Map<String, dynamic> json) => CV(
        name: json['name'] ?? '',
        title: json['title'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        location: json['location'] ?? '',
        linkedin: json['linkedin'] ?? '',
        github: json['github'] ?? '',
        summary: json['summary'] ?? '',
        education: Education.fromJson(json['education'] ?? {}),
        skills: (json['skills'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        experience: (json['experience'] as List<dynamic>? ?? []).map((e) => Experience.fromJson(e)).toList(),
        projects: (json['projects'] as List<dynamic>? ?? []).map((e) => Project.fromJson(e)).toList(),
        links: Links.fromJson(json['links'] ?? {}),
      );
}

class Education {
  final String degree;
  final String university;
  final String period;
  final String location;
  Education({required this.degree, required this.university, required this.period, required this.location});
  factory Education.fromJson(Map<String, dynamic> json) => Education(
        degree: json['degree'] ?? '',
        university: json['university'] ?? '',
        period: json['period'] ?? '',
        location: json['location'] ?? '',
      );
}

class Experience {
  final String company;
  final String role;
  final String period;
  final String location;
  final List<String> highlights;
  Experience({required this.company, required this.role, required this.period, required this.location, required this.highlights});
  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        company: json['company'] ?? '',
        role: json['role'] ?? '',
        period: json['period'] ?? '',
        location: json['location'] ?? '',
        highlights: (json['highlights'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}

class Project {
  final String name;
  final String period;
  final String description;
  final List<String> stores;
  Project({required this.name, required this.period, required this.description, required this.stores});
  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] ?? '',
        period: json['period'] ?? '',
        description: json['description'] ?? '',
        stores: (json['stores'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}

class Links {
  final List<String> appStoreExamples;
  final List<String> playStoreExamples;
  Links({required this.appStoreExamples, required this.playStoreExamples});
  factory Links.fromJson(Map<String, dynamic> json) => Links(
        appStoreExamples: (json['app_store_examples'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        playStoreExamples: (json['play_store_examples'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}
