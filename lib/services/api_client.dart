import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception yang dilempar ketika respons HTTP API bukan 2xx atau payload tidak valid.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client untuk berkomunikasi dengan backend Django REST Framework.
class ApiClient {
  /// Batas waktu tunggu default untuk setiap permintaan HTTP.
  static const Duration defaultTimeout = Duration(seconds: 15);

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    this.baseUrl = apiBaseUrl,
    this.timeout = defaultTimeout,
  }) : _client = client ?? http.Client();

  /// Menutup instance [http.Client] yang digunakan oleh [ApiClient].
  void close() => _client.close();

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Map<String, String> _headers({String? token, bool hasJsonBody = false}) {
    return {
      'Accept': 'application/json',
      if (hasJsonBody) 'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  /// Mengambil daftar proyek publik dari `GET /api/v1/projects/`.
  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(_uri('/api/v1/projects/'), headers: _headers())
        .timeout(timeout);
    _ensureSuccess(response);

    final decoded = _decodeJson(response);
    if (decoded is! List) {
      throw ApiException(
        response.statusCode,
        'Format respons daftar proyek tidak valid.',
      );
    }

    try {
      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Item proyek bukan JSON object.');
        }
        return Project.fromJson(item);
      }).toList();
    } on Object {
      throw ApiException(
        response.statusCode,
        'Data proyek dari server tidak sesuai kontrak.',
      );
    }
  }

  /// Membuat proyek baru melalui `POST /api/v1/projects/` dengan autentikasi token.
  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client
        .post(
          _uri('/api/v1/projects/'),
          headers: _headers(token: token, hasJsonBody: true),
          body: jsonEncode(project.toJson()),
        )
        .timeout(timeout);
    _ensureSuccess(response);

    final decoded = _decodeJson(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        response.statusCode,
        'Format respons proyek tidak valid.',
      );
    }

    try {
      return Project.fromJson(decoded);
    } on Object {
      throw ApiException(
        response.statusCode,
        'Data proyek dari server tidak sesuai kontrak.',
      );
    }
  }

  /// Menukarkan username dan password menjadi DRF auth token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/token/'),
          headers: _headers(hasJsonBody: true),
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(timeout);
    _ensureSuccess(response);

    final decoded = _decodeJson(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        response.statusCode,
        'Format respons autentikasi tidak valid.',
      );
    }

    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw ApiException(
        response.statusCode,
        'Respons autentikasi tidak mengandung token yang valid.',
      );
    }
    return token;
  }

  /// Mencabut auth token aktif di backend melalui `POST /api/v1/auth/logout/`.
  Future<void> logout({required String token}) async {
    final response = await _client
        .post(_uri('/api/v1/auth/logout/'), headers: _headers(token: token))
        .timeout(timeout);
    _ensureSuccess(response);
  }

  dynamic _decodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        response.statusCode,
        'Format respons server tidak valid (bukan JSON).',
      );
    }
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, _extractErrorMessage(response));
  }

  String _extractErrorMessage(http.Response response) {
    final trimmed = response.body.trim();
    if (trimmed.isNotEmpty) {
      try {
        final decoded = jsonDecode(trimmed);
        final extracted = _extractFromDecodedError(decoded);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      } on FormatException {
        // Abaikan body non-JSON (mis. halaman HTML 500) dan gunakan pesan ringkas.
      }
    }

    final reason = response.reasonPhrase?.trim();
    if (reason != null && reason.isNotEmpty) {
      return 'Permintaan gagal (HTTP ${response.statusCode}: $reason).';
    }
    return 'Permintaan gagal dengan status HTTP ${response.statusCode}.';
  }

  String? _extractFromDecodedError(dynamic decoded) {
    if (decoded is String) {
      final text = decoded.trim();
      return text.isEmpty ? null : text;
    }

    if (decoded is List) {
      for (final item in decoded) {
        final extracted = _extractFromDecodedError(item);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
      return null;
    }

    if (decoded is Map) {
      for (final priorityKey in const ['detail', 'non_field_errors']) {
        if (decoded.containsKey(priorityKey)) {
          final extracted = _extractFromDecodedError(decoded[priorityKey]);
          if (extracted != null && extracted.isNotEmpty) {
            return extracted;
          }
        }
      }

      for (final entry in decoded.entries) {
        final extracted = _extractFromDecodedError(entry.value);
        if (extracted != null && extracted.isNotEmpty) {
          return '${entry.key}: $extracted';
        }
      }
    }

    return null;
  }
}
