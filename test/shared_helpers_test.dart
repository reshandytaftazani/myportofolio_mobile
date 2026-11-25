import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/date_formatter.dart';
import 'package:myportofolio_mobile/widgets/portfolio_svg_utils.dart';

void main() {
  group('formatIsoDate', () {
    test('formats DateTime with zero-padded year, month, and day', () {
      expect(formatIsoDate(DateTime(2025, 1, 5)), '2025-01-05');
      expect(formatIsoDate(DateTime(2025, 11, 25)), '2025-11-25');
      expect(formatIsoDate(DateTime(999, 3, 9)), '0999-03-09');
    });
  });

  group('portfolio_svg_utils', () {
    test('isSvgDataUri detects SVG data URIs case-insensitively', () {
      expect(isSvgDataUri('data:image/svg+xml;utf8,<svg></svg>'), isTrue);
      expect(isSvgDataUri('DATA:IMAGE/SVG+XML;base64,PHN2Zz4='), isTrue);
      expect(isSvgDataUri('https://example.com/icon.svg'), isFalse);
    });

    test('decodeSvgDataUri decodes utf8 and base64 SVG data URIs', () {
      const svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>';
      final utf8Bytes = decodeSvgDataUri(
        'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}',
      );
      expect(utf8.decode(utf8Bytes), svg);

      final base64Bytes = decodeSvgDataUri(
        'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}',
      );
      expect(utf8.decode(base64Bytes), svg);

      expect(
        () => decodeSvgDataUri('data:image/svg+xml'),
        throwsA(isA<FormatException>()),
      );
    });

    test('validateAndDecodeSvgBytes validates root <svg> element', () {
      const svg = '  <svg viewBox="0 0 10 10"><rect/></svg>  ';
      expect(
        validateAndDecodeSvgBytes(Uint8List.fromList(utf8.encode(svg))),
        svg.trim(),
      );

      expect(
        () => validateAndDecodeSvgBytes(null),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => validateAndDecodeSvgBytes(Uint8List(0)),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => validateAndDecodeSvgBytes(
          Uint8List.fromList(utf8.encode('<html>not svg</html>')),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
