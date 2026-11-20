/// Model data untuk entri Tech Stack pada portofolio.
class TechStack {
  final String name;
  final String iconUrl;
  final String filename;
  final String codeSnippet;
  final int order;

  const TechStack({
    required this.name,
    required this.iconUrl,
    required this.filename,
    required this.codeSnippet,
    this.order = 0,
  });
}
