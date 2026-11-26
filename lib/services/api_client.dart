import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';

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
  Future<List<Project>> getProjects() =>
      _getList('/api/v1/projects/', Project.fromJson, 'proyek');

  /// Membuat proyek baru melalui `POST /api/v1/projects/` dengan autentikasi token.
  Future<Project> createProject(Project project, {required String token}) =>
      _postItem(
        '/api/v1/projects/',
        project.toJson(),
        Project.fromJson,
        token: token,
        resourceLabel: 'proyek',
      );

  /// Menghapus proyek melalui `DELETE /api/v1/projects/<id>/` dengan autentikasi token.
  Future<void> deleteProject(String id, {required String token}) =>
      _deleteItem('/api/v1/projects/${Uri.encodeComponent(id)}/', token: token);

  /// Mengambil daftar pengalaman publik dari `GET /api/v1/experiences/`.
  Future<List<Experience>> getExperiences() =>
      _getList('/api/v1/experiences/', Experience.fromJson, 'pengalaman');

  /// Membuat pengalaman baru melalui `POST /api/v1/experiences/` dengan autentikasi token.
  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) => _postItem(
    '/api/v1/experiences/',
    experience.toJson(),
    Experience.fromJson,
    token: token,
    resourceLabel: 'pengalaman',
  );

  /// Menghapus pengalaman melalui `DELETE /api/v1/experiences/<id>/` dengan autentikasi token.
  Future<void> deleteExperience(String id, {required String token}) =>
      _deleteItem(
        '/api/v1/experiences/${Uri.encodeComponent(id)}/',
        token: token,
      );

  /// Mengambil daftar pendidikan publik dari `GET /api/v1/education/`.
  Future<List<Education>> getEducations() =>
      _getList('/api/v1/education/', Education.fromJson, 'pendidikan');

  /// Membuat pendidikan baru melalui `POST /api/v1/education/` dengan autentikasi token.
  Future<Education> createEducation(
    Education education, {
    required String token,
  }) => _postItem(
    '/api/v1/education/',
    education.toJson(),
    Education.fromJson,
    token: token,
    resourceLabel: 'pendidikan',
  );

  /// Menghapus pendidikan melalui `DELETE /api/v1/education/<id>/` dengan autentikasi token.
  Future<void> deleteEducation(int id, {required String token}) =>
      _deleteItem('/api/v1/education/$id/', token: token);

  /// Mengambil daftar keahlian publik dari `GET /api/v1/skills/`.
  Future<List<Skill>> getSkills() =>
      _getList('/api/v1/skills/', Skill.fromJson, 'keahlian');

  /// Membuat keahlian baru melalui `POST /api/v1/skills/` dengan autentikasi token.
  Future<Skill> createSkill(Skill skill, {required String token}) => _postItem(
    '/api/v1/skills/',
    skill.toJson(),
    Skill.fromJson,
    token: token,
    resourceLabel: 'keahlian',
  );

  /// Menghapus keahlian melalui `DELETE /api/v1/skills/<id>/` dengan autentikasi token.
  Future<void> deleteSkill(String id, {required String token}) =>
      _deleteItem('/api/v1/skills/${Uri.encodeComponent(id)}/', token: token);

  /// Mengambil daftar tech stack publik dari `GET /api/v1/techstacks/`.
  Future<List<TechStack>> getTechStacks() =>
      _getList('/api/v1/techstacks/', TechStack.fromJson, 'tech stack');

  /// Membuat tech stack baru melalui `POST /api/v1/techstacks/` dengan autentikasi token.
  Future<TechStack> createTechStack(
    TechStack techStack, {
    required String token,
  }) => _postItem(
    '/api/v1/techstacks/',
    techStack.toJson(),
    TechStack.fromJson,
    token: token,
    resourceLabel: 'tech stack',
  );

  /// Menghapus tech stack melalui `DELETE /api/v1/techstacks/<id>/` dengan autentikasi token.
  Future<void> deleteTechStack(int id, {required String token}) =>
      _deleteItem('/api/v1/techstacks/$id/', token: token);

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    String resourceLabel,
  ) async {
    final response = await _client
        .get(_uri(path), headers: _headers())
        .timeout(timeout);
    _ensureSuccess(response);

    final decoded = _decodeJson(response);
    if (decoded is! List) {
      throw ApiException(
        response.statusCode,
        'Format respons daftar $resourceLabel tidak valid.',
      );
    }

    try {
      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('Item $resourceLabel bukan JSON object.');
        }
        return fromJson(item);
      }).toList();
    } on Object {
      throw ApiException(
        response.statusCode,
        'Data $resourceLabel dari server tidak sesuai kontrak.',
      );
    }
  }

  Future<T> _postItem<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson, {
    required String token,
    required String resourceLabel,
  }) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers(token: token, hasJsonBody: true),
          body: jsonEncode(body),
        )
        .timeout(timeout);
    _ensureSuccess(response);

    final decoded = _decodeJson(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        response.statusCode,
        'Format respons $resourceLabel tidak valid.',
      );
    }

    try {
      return fromJson(decoded);
    } on Object {
      throw ApiException(
        response.statusCode,
        'Data $resourceLabel dari server tidak sesuai kontrak.',
      );
    }
  }

  Future<void> _deleteItem(String path, {required String token}) async {
    final response = await _client
        .delete(_uri(path), headers: _headers(token: token))
        .timeout(timeout);
    _ensureSuccess(response);
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
