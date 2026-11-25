import 'package:material_ui/material_ui.dart';

/// Ekstensi tema untuk warna blok cuplikan kode pada [CodeSnippetBox].
@immutable
class CodeSnippetTheme extends ThemeExtension<CodeSnippetTheme> {
  final Color backgroundColor;
  final Color textColor;

  const CodeSnippetTheme({
    required this.backgroundColor,
    required this.textColor,
  });

  /// Palet gelap bawaan untuk blok kode.
  const CodeSnippetTheme.dark()
    : backgroundColor = const Color(0xFF1E1E2E),
      textColor = const Color(0xFFE2E8F0);

  @override
  CodeSnippetTheme copyWith({Color? backgroundColor, Color? textColor}) {
    return CodeSnippetTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  CodeSnippetTheme lerp(ThemeExtension<CodeSnippetTheme>? other, double t) {
    if (other is! CodeSnippetTheme) return this;
    return CodeSnippetTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}

/// Kontainer bersama untuk menampilkan blok cuplikan kode bertema konsisten.
class CodeSnippetBox extends StatelessWidget {
  final String code;
  final int? maxLines;
  final bool selectable;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double lineHeight;

  const CodeSnippetBox({
    super.key,
    required this.code,
    this.maxLines,
    this.selectable = false,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 10,
    this.lineHeight = 1.4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeTheme =
        theme.extension<CodeSnippetTheme>() ?? const CodeSnippetTheme.dark();
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: codeTheme.textColor,
      height: lineHeight,
    );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: codeTheme.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: selectable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(code, style: textStyle),
            )
          : Text(
              code,
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
              style: textStyle,
            ),
    );
  }
}
