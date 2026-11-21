import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/profile_header.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Halaman menu utama aplikasi MyPortfolio Mobile.
///
/// Menyajikan ringkasan identitas pemilik portofolio ([ProfileHeader] dan [InfoCard])
/// serta 4 kategori menu utama ([ItemCard]) yang masing-masing menampung aksi
/// lihat dan tambah data.
class MyHomePage extends StatelessWidget {
  /// Membuat instansi [MyHomePage].
  const MyHomePage({super.key});

  final String npm = "2506547651";
  final String nama = "Reshandy Taftazani Aulya";
  final String kelas = "PBP D";

  void _handleLogout(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            "Kamu telah menekan tombol Logout!",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: const LeftDrawer(),
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

            // Bagian tengah: pesan sambutan dan kisi 2x2 menu portofolio.
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

                  GridView.count(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    crossAxisCount: 2,
                    // Tinggi kartu mengikuti skala teks perangkat.
                    mainAxisExtent:
                        144 * MediaQuery.textScalerOf(context).scale(1),
                    shrinkWrap: true,
                    children: portfolioMenuItems
                        .map((item) => ItemCard(item))
                        .toList(),
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
