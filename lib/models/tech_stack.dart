/// Model data untuk entri Tech Stack pada portofolio.
class TechStack {
  final int? id;
  final String name;
  final String iconUrl;
  final String filename;
  final String codeSnippet;
  final int order;
  final int starCount;
  final bool isStarred;
  final String starredByNames;

  const TechStack({
    this.id,
    required this.name,
    required this.iconUrl,
    required this.filename,
    required this.codeSnippet,
    this.order = 0,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat instance [TechStack] dari JSON response API Django.
  factory TechStack.fromJson(Map<String, dynamic> json) {
    return TechStack(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: (json['name'] as String?) ?? '',
      iconUrl: (json['icon_url'] as String?) ?? '',
      filename: (json['filename'] as String?) ?? '',
      codeSnippet: (json['code_snippet'] as String?) ?? '',
      order: json['order'] is int
          ? json['order'] as int
          : int.tryParse('${json['order']}') ?? 0,
      starCount: json['star_count'] is int
          ? json['star_count'] as int
          : int.tryParse('${json['star_count']}') ?? 0,
      isStarred: (json['is_starred'] as bool?) ?? false,
      starredByNames: (json['starred_by_names'] as String?) ?? '',
    );
  }

  /// Mengonversi instance [TechStack] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_url': iconUrl,
      'filename': filename,
      'code_snippet': codeSnippet,
      'order': order,
    };
  }
}
