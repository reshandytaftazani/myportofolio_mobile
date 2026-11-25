import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myportofolio_mobile/widgets/portfolio_svg_utils.dart';

/// Membuat [BytesLoader] untuk platform Web / non-IO tanpa mengimpor `dart:io`.
BytesLoader createPortfolioSvgLoader(String url) {
  if (isSvgDataUri(url)) {
    return _DataUriSvgLoader(url);
  }
  return SvgNetworkLoader(url);
}

class _DataUriSvgLoader extends SvgLoader<String> {
  final String dataUri;

  const _DataUriSvgLoader(this.dataUri);

  @override
  Future<String?> prepareMessage(BuildContext? context) async {
    return validateAndDecodeSvgBytes(decodeSvgDataUri(dataUri));
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
