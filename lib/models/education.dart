import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/json_converters.dart';

part 'education.g.dart';

/// Model data untuk entri Pendidikan (Education) pada portofolio.
@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  @JsonKey(fromJson: parseNullableInt, includeToJson: false)
  final int? id;
  @JsonKey(defaultValue: '')
  final String schoolName;
  @JsonKey(defaultValue: '')
  final String period;
  @JsonKey(defaultValue: '')
  final String detail;
  @JsonKey(fromJson: parseIntOrZero)
  final int startYear;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  const Education({
    this.id,
    required this.schoolName,
    required this.period,
    required this.detail,
    required this.startYear,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat instance [Education] dari JSON response API Django.
  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  /// Mengonversi instance [Education] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() => _$EducationToJson(this);

  /// Membuat salinan [Education] dengan field tertentu yang diperbarui.
  Education copyWith({
    int? id,
    String? schoolName,
    String? period,
    String? detail,
    int? startYear,
    int? starCount,
    bool? isStarred,
    String? starredByNames,
  }) {
    return Education(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      period: period ?? this.period,
      detail: detail ?? this.detail,
      startYear: startYear ?? this.startYear,
      starCount: starCount ?? this.starCount,
      isStarred: isStarred ?? this.isStarred,
      starredByNames: starredByNames ?? this.starredByNames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Education &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            schoolName == other.schoolName &&
            period == other.period &&
            detail == other.detail &&
            startYear == other.startYear &&
            starCount == other.starCount &&
            isStarred == other.isStarred &&
            starredByNames == other.starredByNames;
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolName,
    period,
    detail,
    startYear,
    starCount,
    isStarred,
    starredByNames,
  );
}
