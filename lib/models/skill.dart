import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/json_converters.dart';

part 'skill.g.dart';

/// Model data untuk entri Keahlian (Skill) pada portofolio.
@JsonSerializable(fieldRename: FieldRename.snake)
class Skill {
  @JsonKey(fromJson: parseNullableId, includeToJson: false)
  final String? id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: '')
  final String level;
  final String? codeSnippet;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
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
  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  /// Mengonversi instance [Skill] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() => _$SkillToJson(this);

  /// Membuat salinan [Skill] dengan field tertentu yang diperbarui.
  Skill copyWith({
    String? id,
    String? title,
    String? description,
    String? level,
    String? codeSnippet,
    int? starCount,
    bool? isStarred,
    String? starredByNames,
  }) {
    return Skill(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      starCount: starCount ?? this.starCount,
      isStarred: isStarred ?? this.isStarred,
      starredByNames: starredByNames ?? this.starredByNames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Skill &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description &&
            level == other.level &&
            codeSnippet == other.codeSnippet &&
            starCount == other.starCount &&
            isStarred == other.isStarred &&
            starredByNames == other.starredByNames;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    level,
    codeSnippet,
    starCount,
    isStarred,
    starredByNames,
  );
}
