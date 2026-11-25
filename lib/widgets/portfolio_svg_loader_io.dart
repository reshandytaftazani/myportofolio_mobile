import 'dart:convert' show base64Decode, utf8;
import 'dart:io' show HttpClient, HttpClientRequest, HttpStatus;

import 'package:flutter/foundation.dart'
    show Uint8List, consolidateHttpClientResponseBytes;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

final RegExp _svgRootPattern = RegExp(
  r'<\s*(?:[a-zA-Z0-9_-]+:)?svg\b',
  caseSensitive: false,
);

/// Membuat [BytesLoader] untuk platform IO (Android, iOS, Desktop, dan test)
/// yang kompatibel dengan `HttpOverrides.global`, menutup [HttpClient] setelah
/// selesai, dan menerapkan batas waktu koneksi.
BytesLoader createPortfolioSvgLoader(String url) => _IoPortfolioSvgLoader(url);

class _IoPortfolioSvgLoader extends SvgLoader<Uint8List> {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final String url;

  const _IoPortfolioSvgLoader(this.url);

  Future<HttpClientRequest> _openRequest(HttpClient client, Uri uri) async {
    try {
      return await client.getUrl(uri);
    } on UnimplementedError {
      return await client.openUrl('GET', uri);
    }
  }

  Uint8List _decodeDataUri(String dataUri) {
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

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    if (url.toLowerCase().startsWith('data:image/svg+xml')) {
      return _decodeDataUri(url);
    }

    final uri = Uri.parse(url);
    final client = HttpClient();
    try {
      try {
        client.connectionTimeout = _requestTimeout;
      } on UnimplementedError {
        // Beberapa fake HttpClient di pengujian tidak mengimplementasikan setter ini.
      }
      final request = await _openRequest(client, uri).timeout(_requestTimeout);
      final response = await request.close().timeout(_requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}',
        );
      }
      final bytes = await consolidateHttpClientResponseBytes(response)
          .timeout(_requestTimeout);
      if (bytes.isEmpty) {
        throw const FormatException('Empty SVG response');
      }
      return bytes;
    } finally {
      client.close();
    }
  }

  @override
  String provideSvg(Uint8List? message) {
    if (message == null || message.isEmpty) {
      throw const FormatException('Empty SVG data');
    }
    final decoded = utf8.decode(message, allowMalformed: true).trim();
    if (!_svgRootPattern.hasMatch(decoded)) {
      throw const FormatException('Payload does not contain <svg> root');
    }
    return decoded;
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    return SvgCacheKey(
      keyData: url,
      theme: getTheme(context),
      colorMapper: colorMapper,
    );
  }

  @override
  int get hashCode => Object.hash(url, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is _IoPortfolioSvgLoader &&
        other.url == url &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }
}
