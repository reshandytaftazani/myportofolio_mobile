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

  final String title;
  final String description;
  final String category;
  final String? projectUrl;
  final String? projectImageUrl;
  final bool isFeatured;

  const Project({
    required this.title,
    required this.description,
    this.category = defaultCategory,
    this.projectUrl,
    this.projectImageUrl,
    this.isFeatured = false,
  });
}
