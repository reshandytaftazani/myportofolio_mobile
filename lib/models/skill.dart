/// Model data untuk entri Keahlian (Skill) pada portofolio.
class Skill {
  final String? id;
  final String title;
  final String description;
  final String level;
  final String? codeSnippet;
  final int starCount;
  final bool isStarred;
  final String starredByNames;

  const Skill({
    this.id,
    required this.title,
    required this.description,
    required this.level,
    this.codeSnippet,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat instance [Skill] dari JSON response API Django.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id']?.toString(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      level: (json['level'] as String?) ?? '',
      codeSnippet: json['code_snippet'] as String?,
      starCount: json['star_count'] is int
          ? json['star_count'] as int
          : int.tryParse('${json['star_count']}') ?? 0,
      isStarred: (json['is_starred'] as bool?) ?? false,
      starredByNames: (json['starred_by_names'] as String?) ?? '',
    );
  }

  /// Mengonversi instance [Skill] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'level': level,
      'code_snippet': codeSnippet,
    };
  }
}
