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
        profileImage: json['profileImage'],
        education: Education.fromJson(json['education'] ?? {}),
        skills: (json['skills'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        experience: (json['experience'] as List<dynamic>? ?? []).map((e) => Experience.fromJson(e)).toList(),
        projects: (json['projects'] as List<dynamic>? ?? []).map((e) => Project.fromJson(e)).toList(),
        links: Links.fromJson(json['links'] ?? {}),
      );
      
  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedin': linkedin,
        'github': github,
        'summary': summary,
        'profileImage': profileImage,
        'education': education.toJson(),
        'skills': skills,
        'experience': experience.map((e) => e.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'links': links.toJson(),
      };
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
      
  Map<String, dynamic> toJson() => {
        'degree': degree,
        'university': university,
        'period': period,
        'location': location,
      };
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
      
  Map<String, dynamic> toJson() => {
        'company': company,
        'role': role,
        'period': period,
        'location': location,
        'highlights': highlights,
      };
}

class Project {
  final String name;
  final String period;
  final String description;
  final List<String> technologies;
  final String? link;
  final String? github;
  final List<String> stores; // Keep for backward compatibility
  
  Project({
    required this.name, 
    required this.period, 
    required this.description, 
    required this.technologies,
    this.link,
    this.github,
    List<String>? stores,
  }) : stores = stores ?? technologies; // Use technologies as stores for compatibility
  
  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] ?? '',
        period: json['period'] ?? '',
        description: json['description'] ?? '',
        technologies: (json['technologies'] as List<dynamic>? ?? 
                      json['stores'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        link: json['link'],
        github: json['github'],
        stores: (json['stores'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
      
  Map<String, dynamic> toJson() => {
        'name': name,
        'period': period,
        'description': description,
        'technologies': technologies,
        'stores': stores,
        'link': link,
        'github': github,
      };
}

class Links {
  final List<String> appStoreExamples;
  final List<String> playStoreExamples;
  Links({required this.appStoreExamples, required this.playStoreExamples});
  factory Links.fromJson(Map<String, dynamic> json) => Links(
        appStoreExamples: (json['app_store_examples'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        playStoreExamples: (json['play_store_examples'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
      
  Map<String, dynamic> toJson() => {
        'app_store_examples': appStoreExamples,
        'play_store_examples': playStoreExamples,
      };
}
