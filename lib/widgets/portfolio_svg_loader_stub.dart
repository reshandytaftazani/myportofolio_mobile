import 'dart:convert' show base64Decode, utf8;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

final RegExp _svgRootPattern = RegExp(
  r'<\s*(?:[a-zA-Z0-9_-]+:)?svg\b',
  caseSensitive: false,
);

/// Membuat [BytesLoader] untuk platform Web / non-IO tanpa mengimpor `dart:io`.
BytesLoader createPortfolioSvgLoader(String url) {
  if (url.toLowerCase().startsWith('data:image/svg+xml')) {
    return _DataUriSvgLoader(url);
  }
  return SvgNetworkLoader(url);
}

class _DataUriSvgLoader extends SvgLoader<String> {
  final String dataUri;

  const _DataUriSvgLoader(this.dataUri);

  @override
  Future<String?> prepareMessage(BuildContext? context) async {
    final commaIndex = dataUri.indexOf(',');
    if (commaIndex == -1) {
      throw const FormatException('Invalid SVG data URI');
    }
    final metadata = dataUri.substring(0, commaIndex).toLowerCase();
    final payload = dataUri.substring(commaIndex + 1);
    final decoded = metadata.contains(';base64')
        ? utf8.decode(base64Decode(payload), allowMalformed: true).trim()
        : Uri.decodeFull(payload).trim();
    if (!_svgRootPattern.hasMatch(decoded)) {
      throw const FormatException('Payload does not contain <svg> root');
    }
    return decoded;
  }

  @override
  String provideSvg(String? message) {
    if (message == null || message.isEmpty) {
      throw const FormatException('Empty SVG data');
    }
    return message;
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    return SvgCacheKey(
      keyData: dataUri,
      theme: getTheme(context),
      colorMapper: colorMapper,
    );
  }

  @override
  int get hashCode => Object.hash(dataUri, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is _DataUriSvgLoader &&
        other.dataUri == dataUri &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }
}
