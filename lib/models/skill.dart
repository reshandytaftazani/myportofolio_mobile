/// Model data untuk entri Keahlian (Skill) pada portofolio.
class Skill {
  final String title;
  final String description;
  final String level;
  final String? codeSnippet;

  const Skill({
    required this.title,
    required this.description,
    required this.level,
    this.codeSnippet,
  });
}
