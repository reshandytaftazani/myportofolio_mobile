import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/json_converters.dart';

part 'tech_stack.g.dart';

/// Model data untuk entri Tech Stack pada portofolio.
@JsonSerializable(fieldRename: FieldRename.snake)
class TechStack {
  @JsonKey(fromJson: parseNullableInt, includeToJson: false)
  final int? id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String iconUrl;
  @JsonKey(defaultValue: '')
  final String filename;
  @JsonKey(defaultValue: '')
  final String codeSnippet;
  @JsonKey(fromJson: parseIntOrZero)
  final int order;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
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
  factory TechStack.fromJson(Map<String, dynamic> json) =>
      _$TechStackFromJson(json);

  /// Mengonversi instance [TechStack] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() => _$TechStackToJson(this);

  /// Membuat salinan [TechStack] dengan field tertentu yang diperbarui.
  TechStack copyWith({
    int? id,
    String? name,
    String? iconUrl,
    String? filename,
    String? codeSnippet,
    int? order,
    int? starCount,
    bool? isStarred,
    String? starredByNames,
  }) {
    return TechStack(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      filename: filename ?? this.filename,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      order: order ?? this.order,
      starCount: starCount ?? this.starCount,
      isStarred: isStarred ?? this.isStarred,
      starredByNames: starredByNames ?? this.starredByNames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TechStack &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            iconUrl == other.iconUrl &&
            filename == other.filename &&
            codeSnippet == other.codeSnippet &&
            order == other.order &&
            starCount == other.starCount &&
            isStarred == other.isStarred &&
            starredByNames == other.starredByNames;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconUrl,
    filename,
    codeSnippet,
    order,
    starCount,
    isStarred,
    starredByNames,
  );
}
