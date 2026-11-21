/// Model data untuk entri Pendidikan (Education) pada portofolio.
class Education {
  final int? id;
  final String schoolName;
  final String period;
  final String detail;
  final int startYear;
  final int starCount;
  final bool isStarred;
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
  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      schoolName: (json['school_name'] as String?) ?? '',
      period: (json['period'] as String?) ?? '',
      detail: (json['detail'] as String?) ?? '',
      startYear: json['start_year'] is int
          ? json['start_year'] as int
          : int.tryParse('${json['start_year']}') ?? 0,
      starCount: json['star_count'] is int
          ? json['star_count'] as int
          : int.tryParse('${json['star_count']}') ?? 0,
      isStarred: (json['is_starred'] as bool?) ?? false,
      starredByNames: (json['starred_by_names'] as String?) ?? '',
    );
  }

  /// Mengonversi instance [Education] ke Map JSON untuk dikirim ke API Django.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'school_name': schoolName,
      'period': period,
      'detail': detail,
      'start_year': startYear,
    };
  }
}
