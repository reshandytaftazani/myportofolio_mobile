import 'package:flutter/material.dart';

/// Model data yang merepresentasikan item menu aksi pada halaman utama portofolio.
///
/// Setiap item memiliki label ([name]), ikon representatif ([icon]),
/// serta warna latar belakang kartu ([color]) yang unik dan bermakna semantik.
class ItemHomepage {
  /// Nama atau judul tombol aksi.
  final String name;

  /// Ikon yang merepresentasikan aksi tombol.
  final IconData icon;

  /// Warna latar belakang kartu tombol aksi.
  final Color color;

  /// Membuat instansi [ItemHomepage] dengan parameter wajib.
  const ItemHomepage(this.name, this.icon, this.color);
}
