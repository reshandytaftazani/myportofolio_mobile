import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Model data untuk entri Proyek (Project) pada portofolio.
@JsonSerializable(fieldRename: FieldRename.snake)
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

  @JsonKey(includeToJson: false)
  final String? id;
  // Dipertahankan wajib non-null tanpa defaultValue agar payload proyek
  // yang rusak (mis. `{'title': null}`) gagal parsing dan ditolak ApiClient.
  final String title;
  final String description;
  @JsonKey(defaultValue: defaultCategory)
  final String category;
  @JsonKey(defaultValue: '')
  final String techStack;
  @JsonKey(defaultValue: '')
  final String projectUrl;
  @JsonKey(defaultValue: '')
  final String projectImageUrl;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  const Project({
    this.id,
    required this.title,
    required this.description,
    this.category = defaultCategory,
    this.techStack = '',
    this.projectUrl = '',
    this.projectImageUrl = '',
    this.isFeatured = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat instance [Project] dari JSON response API Django.
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Mengonversi instance [Project] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// Membuat salinan [Project] dengan field tertentu yang diperbarui.
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? techStack,
    String? projectUrl,
    String? projectImageUrl,
    bool? isFeatured,
    int? starCount,
    bool? isStarred,
    String? starredByNames,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      techStack: techStack ?? this.techStack,
      projectUrl: projectUrl ?? this.projectUrl,
      projectImageUrl: projectImageUrl ?? this.projectImageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      starCount: starCount ?? this.starCount,
      isStarred: isStarred ?? this.isStarred,
      starredByNames: starredByNames ?? this.starredByNames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Project &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description &&
            category == other.category &&
            techStack == other.techStack &&
            projectUrl == other.projectUrl &&
            projectImageUrl == other.projectImageUrl &&
            isFeatured == other.isFeatured &&
            starCount == other.starCount &&
            isStarred == other.isStarred &&
            starredByNames == other.starredByNames;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    techStack,
    projectUrl,
    projectImageUrl,
    isFeatured,
    starCount,
    isStarred,
    starredByNames,
  );
}
