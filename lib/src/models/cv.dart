class CV {
  final String name;
  final String title;
  /// One-line pitch shown in the hero. The longer `summary` lives in About.
  final String headline;
  /// Short "open to…" line shown as a badge under the name. Hidden when empty.
  final String availability;
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String github;
  final String summary;
  /// Optional override for the "years experience" stat. When absent the value
  /// is computed from the earliest experience entry — see `CvStats`.
  final int? yearsExperience;
  /// Free-form reach figure for the stats row, e.g. "250K+". Hidden when null.
  final String? usersReached;
  final String? profileImage; // Can be a URL or base64 string
  final Education education;
  final List<String> skills;
  final List<Experience> experience;
  final List<Project> projects;
  final List<Testimonial> testimonials;

  CV({
    required this.name,
    required this.title,
    this.headline = '',
    this.availability = '',
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.github,
    required this.summary,
    this.yearsExperience,
    this.usersReached,
    this.profileImage,
    required this.education,
    required this.skills,
    required this.experience,
    required this.projects,
    this.testimonials = const [],
  });

  factory CV.fromJson(Map<String, dynamic> json) => CV(
        name: json['name'] ?? '',
        title: json['title'] ?? '',
        headline: json['headline'] ?? '',
        availability: json['availability'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        location: json['location'] ?? '',
        linkedin: json['linkedin'] ?? '',
        github: json['github'] ?? '',
        summary: json['summary'] ?? '',
        yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
        usersReached: json['usersReached'],
        profileImage: json['profileImage'],
        education: Education.fromJson(json['education'] ?? {}),
        skills: (json['skills'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        experience: (json['experience'] as List<dynamic>? ?? []).map((e) => Experience.fromJson(e)).toList(),
        projects: (json['projects'] as List<dynamic>? ?? []).map((e) => Project.fromJson(e)).toList(),
        testimonials: (json['testimonials'] as List<dynamic>? ?? []).map((e) => Testimonial.fromJson(e)).toList(),
      );
      
  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'headline': headline,
        'availability': availability,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedin': linkedin,
        'github': github,
        'summary': summary,
        'yearsExperience': yearsExperience,
        'usersReached': usersReached,
        'profileImage': profileImage,
        'education': education.toJson(),
        'skills': skills,
        'experience': experience.map((e) => e.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'testimonials': testimonials.map((t) => t.toJson()).toList(),
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
  final String? image;
  final String period;
  final String description;
  /// Case-study bullets (problem, role, hard part, result) shown in the dialog.
  final List<String> highlights;
  final List<String> technologies;
  final List<String>? screenshots;
  final String? link;
  final String? github;
  final List<String> stores; // Keep for backward compatibility

  Project({
    required this.name,
    this.image,
    required this.period,
    required this.description,
    this.highlights = const [],
    required this.technologies,
    this.screenshots,
    this.link,
    this.github,
    List<String>? stores,
  }) : stores = stores ?? [];

  /// Store links first, then the project's own site and repository.
  List<String> get allLinks => [
        ...stores,
        if (link != null && link!.isNotEmpty) link!,
        if (github != null && github!.isNotEmpty) github!,
      ];

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] ?? '',
        image: json['image'],
        period: json['period'] ?? '',
        description: json['description'] ?? '',
        highlights: (json['highlights'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        technologies: (json['technologies'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        screenshots: (json['screenshots'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        link: json['link'],
        github: json['github'],
        stores: (json['stores'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'period': period,
        'description': description,
        'highlights': highlights,
        'technologies': technologies,
        'screenshots': screenshots,
        'stores': stores,
        'link': link,
        'github': github,
      };
}

class Testimonial {
  final String quote;
  final String author;
  final String role;
  Testimonial({required this.quote, required this.author, required this.role});
  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
        quote: json['quote'] ?? '',
        author: json['author'] ?? '',
        role: json['role'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'quote': quote,
        'author': author,
        'role': role,
      };
}
