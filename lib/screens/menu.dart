import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/data/portfolio_menu.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/profile_header.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

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

  Future<void> _handleLogout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthState>().logout();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Berhasil logout.',
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

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

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
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _handleLogout(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Login',
              onPressed: () => _openLogin(context),
            ),
        ],
      ),
      drawer: const LeftDrawer(isHome: true),
      // Body halaman utama dengan dukungan scrolling responsif.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            const infoSpacing = 8.0;
            final stackInfoCards = maxWidth < 300;

            const menuSpacing = 12.0;
            final menuColumns = maxWidth < 260 ? 1 : 2;
            final menuCardWidth =
                (maxWidth - menuSpacing * (menuColumns - 1)) / menuColumns;

            final infoItems = [
              (title: 'NPM', content: npm),
              (title: 'Name', content: nama),
              (title: 'Class', content: kelas),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header profil visual pemilik portofolio.
                ProfileHeader(name: nama),

                // Ringkasan identitas adaptif dengan tinggi kartu seragam saat sejajar.
                if (stackInfoCards)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < infoItems.length; i++) ...[
                        if (i > 0) const SizedBox(height: infoSpacing),
                        InfoCard(
                          title: infoItems[i].title,
                          content: infoItems[i].content,
                        ),
                      ],
                    ],
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < infoItems.length; i++) ...[
                          if (i > 0) const SizedBox(width: infoSpacing),
                          Expanded(
                            child: InfoCard(
                              title: infoItems[i].title,
                              content: infoItems[i].content,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 16.0),

                // Bagian tengah: pesan sambutan dan kartu menu portofolio.
                const Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 20.0),
                  child: Text(
                    'Selamat datang di MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),

                Wrap(
                  spacing: menuSpacing,
                  runSpacing: menuSpacing,
                  children: portfolioMenuItems
                      .map(
                        (item) => SizedBox(
                          width: menuCardWidth,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 136),
                            child: ItemCard(item),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
