import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/profile_header.dart';

/// Halaman menu utama aplikasi MyPortfolio Mobile.
///
/// Menyajikan ringkasan identitas pemilik portofolio ([ProfileHeader] dan [InfoCard])
/// serta menu tombol aksi interaktif berkode warna ([ItemCard]).
class MyHomePage extends StatelessWidget {
  /// Membuat instansi [MyHomePage].
  MyHomePage({super.key});

  final String npm = "2506547651";
  final String nama = "Reshandy Taftazani Aulya";
  final String kelas = "PBP D";

  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.indigo),
    ItemHomepage("Lihat Education", Icons.school, const Color(0xFF00695C)),
    ItemHomepage("Lihat Skills", Icons.code, const Color(0xFF6A1B9A)),
    ItemHomepage("Lihat Experience", Icons.work, const Color(0xFF01579B)),
    ItemHomepage("Tambah Proyek", Icons.add_circle, const Color(0xFF2E7D32)),
    ItemHomepage("Logout", Icons.logout, const Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // Body halaman utama dengan dukungan scrolling responsif.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header profil visual pemilik portofolio.
            ProfileHeader(name: nama),

            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // Dua kolom pada ruang sempit, tiga kolom pada ruang lebar.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: constraints.maxWidth >= 600 ? 3 : 2,
                        // Tinggi kartu mengikuti skala teks perangkat.
                        mainAxisExtent:
                            144 * MediaQuery.textScalerOf(context).scale(1),
                        shrinkWrap: true,
                        children: items.map((item) => ItemCard(item)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
