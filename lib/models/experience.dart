/// Model data untuk entri Pengalaman (Experience) pada portofolio.
class Experience {
  /// Pilihan kategori pengalaman sesuai model Django.
  static const Map<String, String> categoryChoices = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
    'organization': 'Organization',
    'competition': 'Competition',
  };

  /// Nilai kategori bawaan sesuai model Django.
  static const String defaultCategory = 'full-time';

  final String title;
  final String? company;
  final String description;
  final String category;

  const Experience({
    required this.title,
    this.company,
    required this.description,
    this.category = defaultCategory,
  });

  /// Label tampilan yang ramah pengguna untuk [category].
  String get categoryLabel => categoryChoices[category] ?? category;
}
