import 'package:flutter/material.dart';

/// Identitas stabil untuk setiap bagian utama portofolio.
enum PortfolioSection { projects, experiences, education, skills }

/// Ekstensi rute bernama stabil untuk setiap [PortfolioSection].
extension PortfolioSectionRoute on PortfolioSection {
  /// Nama rute standar untuk bagian portofolio ini.
  String get routeName => '/section/$name';
}

/// Mengembalikan [PortfolioSection] yang cocok dengan [routeName],
/// atau `null` bila rute bukan rute kategori yang dikenal.
///
/// Menormalisasi path URI (mengabaikan query/fragment dan garis miring
/// penutup berlebih) agar tautan langsung atau refresh URL web tetap cocok.
PortfolioSection? portfolioSectionFromRouteName(String? routeName) {
  if (routeName == null || routeName.isEmpty) return null;
  final uri = Uri.tryParse(routeName);
  if (uri == null) return null;
  var path = uri.path;
  while (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  for (final section in PortfolioSection.values) {
    if (section.routeName == path) {
      return section;
    }
  }
  return null;
}

/// Konfigurasi metadata statis untuk satu kategori utama portofolio,
/// terpisah dari logika navigasi dan pemuatan data.
class PortfolioCategoryConfig {
  /// Identitas stabil bagian portofolio.
  final PortfolioSection section;

  /// Nama atau judul kategori menu.
  final String name;

  /// Keterangan singkat isi kategori.
  final String subtitle;

  /// Ikon yang merepresentasikan kategori.
  final IconData icon;

  /// Warna aksen ikon dan indikator kartu.
  final Color color;

  /// Membuat instansi [PortfolioCategoryConfig].
  const PortfolioCategoryConfig({
    required this.section,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  /// Nama rute standar untuk kategori ini.
  String get routeName => section.routeName;
}

/// Daftar konfigurasi 4 kategori utama portofolio yang murni deklaratif.
const List<PortfolioCategoryConfig> portfolioCategoryConfigs = [
  PortfolioCategoryConfig(
    section: PortfolioSection.projects,
    name: 'Projects',
    subtitle: 'Projects & Tech Stack',
    icon: Icons.folder_outlined,
    color: Colors.indigo,
  ),
  PortfolioCategoryConfig(
    section: PortfolioSection.experiences,
    name: 'Experiences',
    subtitle: 'Kerja & Organisasi',
    icon: Icons.work_outline,
    color: Color(0xFF0277BD),
  ),
  PortfolioCategoryConfig(
    section: PortfolioSection.education,
    name: 'Education',
    subtitle: 'Riwayat Akademik',
    icon: Icons.school_outlined,
    color: Color(0xFF00695C),
  ),
  PortfolioCategoryConfig(
    section: PortfolioSection.skills,
    name: 'Skills',
    subtitle: 'Skill & Kode',
    icon: Icons.code_rounded,
    color: Color(0xFF6A1B9A),
  ),
];

/// Mengambil konfigurasi kategori untuk [section] tertentu.
PortfolioCategoryConfig categoryConfigForSection(PortfolioSection section) {
  return portfolioCategoryConfigs.firstWhere(
    (config) => config.section == section,
  );
}

/// Model data yang merepresentasikan item menu kategori pada halaman utama portofolio.
///
/// Setiap item memiliki identitas bagian ([section]), judul ([name]),
/// keterangan singkat ([subtitle]), ikon representatif ([icon]),
/// warna aksen ([color]), dan halaman tujuan ([pageBuilder]).
class ItemHomepage extends PortfolioCategoryConfig {
  /// Builder halaman tujuan saat kartu ditekan.
  final WidgetBuilder pageBuilder;

  /// Membuat instansi [ItemHomepage].
  const ItemHomepage({
    required super.section,
    required super.name,
    required super.subtitle,
    required super.icon,
    required super.color,
    required this.pageBuilder,
  });
}
