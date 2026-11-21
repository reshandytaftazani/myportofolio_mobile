import 'package:material_ui/material_ui.dart';

/// Model data yang merepresentasikan item menu kategori pada halaman utama portofolio.
///
/// Setiap item memiliki judul ([name]), keterangan singkat ([subtitle]),
/// ikon representatif ([icon]), warna aksen ([color]), dan halaman tujuan ([pageBuilder]).
class ItemHomepage {
  /// Nama atau judul kategori menu.
  final String name;

  /// Keterangan singkat isi kategori.
  final String subtitle;

  /// Ikon yang merepresentasikan kategori.
  final IconData icon;

  /// Warna aksen ikon dan indikator kartu.
  final Color color;

  /// Builder halaman tujuan saat kartu ditekan.
  final WidgetBuilder pageBuilder;

  /// Membuat instansi [ItemHomepage].
  const ItemHomepage({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pageBuilder,
  });
}
