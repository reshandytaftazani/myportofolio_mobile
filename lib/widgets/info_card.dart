import 'package:material_ui/material_ui.dart';

/// Widget kartu informasi yang menampilkan judul ([title]) dan isi ([content]).
///
/// Kartu ini digunakan untuk menyajikan data identitas pemilik portofolio
/// seperti NPM, Nama Lengkap, dan Kelas secara proporsional dan elegan.
class InfoCard extends StatelessWidget {
  /// Judul atau label kategori informasi (misalnya: 'NPM', 'Name', 'Class').
  final String title;

  /// Isi konten informasi yang bersesuaian dengan judul.
  final String content;

  /// Membuat instansi [InfoCard].
  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
