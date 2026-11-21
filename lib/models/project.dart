/// Model data untuk entri Proyek (Project) pada portofolio.
class Project {
  /// Pilihan kategori proyek yang tersedia pada form.
  static const List<String> categoryChoices = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  /// Kategori bawaan sesuai model Django.
  static const String defaultCategory = 'Other';

  final String? id;
  final String title;
  final String description;
  final String category;
  final String? techStack;
  final String? projectUrl;
  final String? projectImageUrl;
  final bool isFeatured;
  final int starCount;
  final bool isStarred;
  final String starredByNames;

  const Project({
    this.id,
    required this.title,
    required this.description,
    this.category = defaultCategory,
    this.techStack,
    this.projectUrl,
    this.projectImageUrl,
    this.isFeatured = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat instance [Project] dari JSON response API Django.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? defaultCategory,
      techStack: json['tech_stack'] as String?,
      projectUrl: json['project_url'] as String?,
      projectImageUrl: json['project_image_url'] as String?,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      starCount: json['star_count'] is int
          ? json['star_count'] as int
          : int.tryParse('${json['star_count']}') ?? 0,
      isStarred: (json['is_starred'] as bool?) ?? false,
      starredByNames: (json['starred_by_names'] as String?) ?? '',
    );
  }

  /// Mengonversi instance [Project] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      if (techStack != null) 'tech_stack': techStack,
      'project_url': projectUrl,
      'project_image_url': projectImageUrl,
      'is_featured': isFeatured,
    };
  }
}
