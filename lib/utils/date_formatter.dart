/// Helper pemformatan tanggal bersama untuk model dan formulir.
library;

/// Memformat [DateTime] menjadi string tanggal ISO `YYYY-MM-DD`.
String formatIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
