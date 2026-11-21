/// Status akhir dari sebuah entri [Experience].
enum ExperienceEndStatus {
  /// Pengalaman masih berlangsung (`isOngoing == true`).
  ongoing,

  /// Pengalaman memiliki tanggal selesai (`!isOngoing && endedAt != null`).
  completed,

  /// Pengalaman tidak sedang berlangsung dan tanggal selesai belum diketahui.
  unknown,
}

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

  final String? id;
  final String title;
  final String? company;
  final String description;
  final String category;
  final String? categoryDisplay;
  final String? thumbnail;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isOngoing;
  final int starCount;
  final bool isStarred;
  final String starredByNames;

  const Experience({
    this.id,
    required this.title,
    this.company,
    required this.description,
    this.category = defaultCategory,
    this.categoryDisplay,
    this.thumbnail,
    this.startedAt,
    this.endedAt,
    this.isOngoing = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Label tampilan yang ramah pengguna untuk [category].
  String get categoryLabel =>
      categoryDisplay ?? categoryChoices[category] ?? category;

  /// Menentukan status akhir pengalaman secara konsisten untuk kartu dan detail.
  ExperienceEndStatus get endStatus {
    if (isOngoing) return ExperienceEndStatus.ongoing;
    if (endedAt != null) return ExperienceEndStatus.completed;
    return ExperienceEndStatus.unknown;
  }

  /// Membuat instance [Experience] dari JSON response API Django.
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id']?.toString(),
      title: (json['title'] as String?) ?? '',
      company: json['company'] as String?,
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? defaultCategory,
      categoryDisplay: json['category_display'] as String?,
      thumbnail: json['thumbnail'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      isOngoing: (json['is_ongoing'] as bool?) ?? false,
      starCount: json['star_count'] is int
          ? json['star_count'] as int
          : int.tryParse('${json['star_count']}') ?? 0,
      isStarred: (json['is_starred'] as bool?) ?? false,
      starredByNames: (json['starred_by_names'] as String?) ?? '',
    );
  }

  /// Mengonversi instance [Experience] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'company': company,
      'description': description,
      'category': category,
      'thumbnail': thumbnail,
      'started_at': startedAt != null ? _formatDate(startedAt!) : null,
      'ended_at': endedAt != null ? _formatDate(endedAt!) : null,
    };
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
