/// Memvalidasi URL HTTP/HTTPS opsional maupun wajib dengan batas panjang.
String? validateHttpUrl(
  String? value, {
  required String fieldLabel,
  bool required = false,
  int maxLength = 200,
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? '$fieldLabel tidak boleh kosong.' : null;
  }

  if (trimmed.length > maxLength) {
    return '$fieldLabel maksimal $maxLength karakter.';
  }
  if (trimmed.contains(RegExp(r'\s'))) {
    return '$fieldLabel tidak boleh mengandung spasi.';
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return 'Gunakan URL HTTP/HTTPS yang valid dengan hostname.';
  }
  return null;
}
