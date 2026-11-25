import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myportofolio_mobile/widgets/portfolio_svg_loader_stub.dart'
    if (dart.library.io) 'package:myportofolio_mobile/widgets/portfolio_svg_loader_io.dart';
import 'package:myportofolio_mobile/widgets/portfolio_svg_utils.dart';

/// Mengecek apakah [url] merujuk pada berkas atau data URI berformat SVG.
bool isSvgImageUrl(String url) {
  final trimmed = url.trim().toLowerCase();
  if (trimmed.isEmpty) return false;
  if (isSvgDataUri(trimmed)) return true;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed.endsWith('.svg');
  if (uri.path.toLowerCase().endsWith('.svg')) return true;
  final formatParam = uri.queryParameters['format']?.toLowerCase();
  return formatParam == 'svg';
}

/// Widget gambar jaringan serbaguna untuk portofolio yang mendukung:
/// 1. Dekode ikon/gambar vektor `.svg` menggunakan [SvgPicture] secara aman
///    lintas platform (Web & IO via conditional import).
/// 2. Pembatasan ukuran dekode bitmap raster ([ResizeImage]) sesuai area tampil
///    logis × `devicePixelRatio` tanpa mendistorsi rasio aspek asli gambar.
class PortfolioNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final WidgetBuilder fallbackBuilder;

  const PortfolioNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.fallbackBuilder,
  });

  int? _computeCacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final physical = (logicalSize * devicePixelRatio).round();
    return physical > 0 ? physical : null;
  }

  ImageProvider<Object> _buildBoundedProvider(
    String url,
    int? cacheWidth,
    int? cacheHeight,
  ) {
    final baseProvider = NetworkImage(url);
    if (cacheWidth == null && cacheHeight == null) {
      return baseProvider;
    }

    // Untuk BoxFit.contain / scaleDown, batasi kedua sisi dengan policy fit
    // agar rasio aspek tetap terjaga dan tidak melebihi area tampil.
    if (fit == BoxFit.contain || fit == BoxFit.scaleDown) {
      return ResizeImage(
        baseProvider,
        width: cacheWidth,
        height: cacheHeight,
        policy: ResizeImagePolicy.fit,
      );
    }

    // Untuk BoxFit.cover dan mode lainnya, batasi satu sumbu saja (prioritas
    // lebar) agar engine mempertahankan rasio aspek asli tanpa memipihkan gambar.
    return ResizeImage(
      baseProvider,
      width: cacheWidth,
      height: cacheWidth == null ? cacheHeight : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return fallbackBuilder(context);
    }

    if (isSvgImageUrl(trimmed)) {
      return SvgPicture(
        createPortfolioSvgLoader(trimmed),
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => SizedBox(width: width, height: height),
        errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final effectiveWidth =
            width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : null);
        final effectiveHeight =
            height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : null);

        final cacheWidth = _computeCacheDimension(effectiveWidth, dpr);
        final cacheHeight = _computeCacheDimension(effectiveHeight, dpr);

        return Image(
          image: _buildBoundedProvider(trimmed, cacheWidth, cacheHeight),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              fallbackBuilder(context),
        );
      },
    );
  }
}
