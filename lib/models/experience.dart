import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/json_converters.dart';

part 'experience.g.dart';

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
@JsonSerializable(fieldRename: FieldRename.snake)
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

  @JsonKey(fromJson: parseNullableId, includeIfNull: false)
  final String? id;
  @JsonKey(defaultValue: '')
  final String title;
  final String? company;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: defaultCategory)
  final String category;
  @JsonKey(includeToJson: false)
  final String? categoryDisplay;
  final String? thumbnail;
  @JsonKey(fromJson: parseNullableDateTime, toJson: formatNullableIsoDate)
  final DateTime? startedAt;
  @JsonKey(fromJson: parseNullableDateTime, toJson: formatNullableIsoDate)
  final DateTime? endedAt;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isOngoing;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
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
  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Mengonversi instance [Experience] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() => _$ExperienceToJson(this);

  /// Membuat salinan [Experience] dengan field tertentu yang diperbarui.
  Experience copyWith({
    String? id,
    String? title,
    String? company,
    String? description,
    String? category,
    String? categoryDisplay,
    String? thumbnail,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isOngoing,
    int? starCount,
    bool? isStarred,
    String? starredByNames,
  }) {
    return Experience(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryDisplay: categoryDisplay ?? this.categoryDisplay,
      thumbnail: thumbnail ?? this.thumbnail,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isOngoing: isOngoing ?? this.isOngoing,
      starCount: starCount ?? this.starCount,
      isStarred: isStarred ?? this.isStarred,
      starredByNames: starredByNames ?? this.starredByNames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Experience &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            company == other.company &&
            description == other.description &&
            category == other.category &&
            categoryDisplay == other.categoryDisplay &&
            thumbnail == other.thumbnail &&
            startedAt == other.startedAt &&
            endedAt == other.endedAt &&
            isOngoing == other.isOngoing &&
            starCount == other.starCount &&
            isStarred == other.isStarred &&
            starredByNames == other.starredByNames;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    company,
    description,
    category,
    categoryDisplay,
    thumbnail,
    startedAt,
    endedAt,
    isOngoing,
    starCount,
    isStarred,
    starredByNames,
  );
}
