import 'dart:io' show HttpClient, HttpClientRequest, HttpStatus;

import 'package:flutter/foundation.dart'
    show Uint8List, consolidateHttpClientResponseBytes;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myportofolio_mobile/widgets/portfolio_svg_utils.dart';

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

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    if (isSvgDataUri(url)) {
      return decodeSvgDataUri(url);
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
  String provideSvg(Uint8List? message) => validateAndDecodeSvgBytes(message);

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
