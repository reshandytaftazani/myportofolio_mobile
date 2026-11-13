import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';

/// Widget kartu tombol aksi pada menu beranda portofolio.
///
/// Kartu ini menampilkan ikon dan nama item portofolio dengan latar belakang
/// berwarna dinamis sesuai konfigurasi [ItemHomepage.color]. Ketika ditekan,
/// kartu akan memunculkan [SnackBar] dengan pesan konfirmasi interaktif.
class ItemCard extends StatelessWidget {
  /// Data konfigurasi item yang dirender oleh kartu ini.
  final ItemHomepage item;

  /// Membuat instansi [ItemCard].
  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menentukan warna latar kartu secara dinamis dari properti item.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Menampilkan SnackBar interaktif dengan warna harmonis dan aksi tutup instan.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  "Kamu telah menekan tombol ${item.name}!",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                backgroundColor: item.color,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'TUTUP',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
