/// Helper parsing dan formatting JSON bersama untuk model-model di `lib/models/`.
library;

import 'package:myportofolio_mobile/utils/date_formatter.dart';

/// Mengurai nilai JSON dinamis menjadi [int] nullable (mendukung `num` dan `String`).
int? parseNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Mengurai nilai JSON dinamis menjadi [int] dengan fallback `0`.
int parseIntOrZero(Object? value) => parseNullableInt(value) ?? 0;

/// Mengurai nilai ID dinamis (`int` atau `String`) menjadi [String] nullable.
String? parseNullableId(Object? value) => value?.toString();

/// Mengurai nilai tanggal JSON dinamis menjadi [DateTime] nullable.
DateTime? parseNullableDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

/// Memformat [DateTime] nullable menjadi string tanggal `YYYY-MM-DD`.
String? formatNullableIsoDate(DateTime? date) =>
    date == null ? null : formatIsoDate(date);
