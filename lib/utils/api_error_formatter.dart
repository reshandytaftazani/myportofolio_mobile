import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/network_error_stub.dart'
    if (dart.library.io) 'package:myportofolio_mobile/utils/network_error_io.dart';

final RegExp _htmlMarkupPattern = RegExp(
  r'<\s*(?:!doctype|html|head|body|title|h1|p|div)\b',
  caseSensitive: false,
);

/// Mengubah objek error jaringan/API menjadi pesan yang ramah bagi pengguna.
///
/// Menangani [ApiException] (tanpa membocorkan markup HTML mentah),
/// [TimeoutException], [http.ClientException], serta `SocketException` lintas
/// platform melalui conditional import.
String formatApiError(Object error, {String? actionLabel}) {
  if (error is TimeoutException) {
    return 'Koneksi ke server habis waktu. Periksa jaringan lalu coba lagi.';
  }

  if (isNetworkSocketException(error) || error is http.ClientException) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }

  if (error is ApiException) {
    final trimmed = error.message.trim();
    final safeMessage = trimmed.isEmpty || _htmlMarkupPattern.hasMatch(trimmed)
        ? 'Terjadi kesalahan pada server.'
        : trimmed;

    if (actionLabel != null && actionLabel.isNotEmpty) {
      return '$actionLabel (${error.statusCode}): $safeMessage';
    }
    return safeMessage;
  }

  if (actionLabel != null && actionLabel.isNotEmpty) {
    return '$actionLabel. Terjadi kesalahan tak terduga.';
  }
  return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
}
