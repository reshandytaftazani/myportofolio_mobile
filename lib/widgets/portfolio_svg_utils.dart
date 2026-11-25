import 'dart:convert' show base64Decode, utf8;
import 'dart:typed_data' show Uint8List;

/// Pola regex untuk memverifikasi adanya elemen root `<svg>` pada payload SVG.
final RegExp svgRootPattern = RegExp(
  r'<\s*(?:[a-zA-Z0-9_-]+:)?svg\b',
  caseSensitive: false,
);

/// Mengecek apakah [url] merupakan Data URI bertipe `image/svg+xml`.
bool isSvgDataUri(String url) =>
    url.toLowerCase().startsWith('data:image/svg+xml');

/// Mendekode Data URI SVG (base64 maupun UTF-8/URL-encoded) menjadi byte mentah.
Uint8List decodeSvgDataUri(String dataUri) {
  final commaIndex = dataUri.indexOf(',');
  if (commaIndex == -1) {
    throw const FormatException('Invalid SVG data URI');
  }
  final metadata = dataUri.substring(0, commaIndex).toLowerCase();
  final payload = dataUri.substring(commaIndex + 1);
  if (metadata.contains(';base64')) {
    return base64Decode(payload);
  }
  return Uint8List.fromList(utf8.encode(Uri.decodeFull(payload)));
}

/// Memvalidasi bahwa [bytes] tidak kosong dan mengandung elemen root `<svg>`,
/// lalu mengembalikan markup SVG yang sudah di-trim.
String validateAndDecodeSvgBytes(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) {
    throw const FormatException('Empty SVG data');
  }
  final decoded = utf8.decode(bytes, allowMalformed: true).trim();
  if (!svgRootPattern.hasMatch(decoded)) {
    throw const FormatException('Payload does not contain <svg> root');
  }
  return decoded;
}
