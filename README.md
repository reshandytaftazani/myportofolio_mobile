# MyPortfolio Mobile

Aplikasi portofolio pribadi multiplatform yang dibuat dengan Flutter sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer, Universitas Indonesia. Proyek mobile ini melengkapi [portofolio web Django](https://github.com/reshandytaftazani/myportofolio) dengan tampilan ringkas untuk perangkat mobile.

![Flutter](https://img.shields.io/badge/Flutter-3.47.9-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)
## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur Proyek](#struktur-proyek)
- [Menjalankan Secara Lokal](#menjalankan-secara-lokal)
- [Pengujian dan Analisis](#pengujian-dan-analisis)
- [Progres Mingguan](#progres-mingguan)
- [Keterbatasan Saat Ini](#keterbatasan-saat-ini)
- [Informasi Pengembang](#informasi-pengembang)

## Tentang Proyek

MyPortfolio Mobile menampilkan identitas pemilik portofolio dan menyediakan menu aksi awal. Aplikasi menggunakan widget Flutter yang dipisahkan berdasarkan tanggung jawab agar model data, komponen tampilan, dan halaman utama lebih mudah dipahami dan dikembangkan.

Proyek ini merupakan pendamping mobile untuk [MyPortfolio berbasis Django](https://github.com/reshandytaftazani/myportofolio). Pada versi saat ini, aplikasi mobile belum mengambil data atau melakukan autentikasi ke layanan web tersebut; konten profil dan menu masih didefinisikan langsung di aplikasi.

## Fitur

- Header profil dengan avatar inisial, nama, deskripsi peran, dan status mahasiswa.
- Kartu informasi untuk NPM, nama, dan kelas.
- Menu aksi Lihat Proyek, Tambah Proyek, dan Logout dengan ikon serta warna berbeda.
- SnackBar kontekstual saat item menu ditekan, dengan tombol untuk menutup notifikasi.
- Tema Material 3 dan tata letak yang dapat digulir.

> Item menu saat ini merupakan demonstrasi interaksi. Item tersebut belum membuka halaman proyek, menambah data, ataupun mengakhiri sesi login.

## Teknologi

- Flutter SDK dan Dart SDK (versi minimum mengikuti batas SDK pada `pubspec.yaml`).
- Material 3 untuk komponen dan tema antarmuka.
- `flutter_lints` untuk aturan analisis statis.
- `flutter_test` untuk dukungan pengujian widget.

Versi Flutter/Dart yang digunakan oleh pengembang dapat berbeda. Untuk melihat versi yang tersedia di mesin Anda, jalankan `flutter --version`.

## Struktur Proyek

```text
lib/
├── main.dart                    # Titik masuk dan konfigurasi aplikasi
├── menu.dart                    # Halaman utama dan data profil/menu
├── models/
│   └── item_homepage.dart       # Model untuk item menu
└── widgets/
    ├── info_card.dart           # Kartu informasi identitas
    ├── item_card.dart           # Kartu aksi dan SnackBar
    └── profile_header.dart      # Header profil
```

## Menjalankan Secara Lokal

### Prasyarat

- Flutter SDK yang kompatibel dengan batas SDK pada `pubspec.yaml`.
- Editor seperti Visual Studio Code dengan ekstensi Flutter atau Android Studio.
- Target untuk menjalankan aplikasi: Chrome, Android Emulator, atau perangkat Android. Target iOS memerlukan macOS dan Xcode.

### Langkah-langkah

1. Clone repositori dan masuk ke direktori proyek:

   ```bash
   git clone https://github.com/reshandytaftazani/myportofolio_mobile.git
   cd myportofolio_mobile
   ```

2. Ambil dependensi:

   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi pada target yang tersedia:

   ```bash
   flutter run
   ```

   Untuk memilih target web secara eksplisit, gunakan `flutter run -d chrome`. Daftar target yang terdeteksi dapat dilihat dengan `flutter devices`.

## Pengujian dan Analisis

Jalankan analisis statis dan pengujian Flutter dari direktori proyek:

```bash
flutter analyze
flutter test
```

`flutter analyze` memeriksa masalah statis sesuai konfigurasi analyzer. `flutter test` menjalankan pengujian yang tersedia di direktori `test/`.

## Progres Mingguan

Ringkasan berikut mencatat perubahan yang terlihat dalam riwayat Git proyek. Minggu mengacu pada tanggal commit; catatan ini bukan bukti waktu pengumpulan tugas.

| Periode / kegiatan | Ringkasan pekerjaan | Bukti di riwayat Git | Status |
| --- | --- | --- | --- |
| 9–15 November 2026 — Tutorial 08 | Menyiapkan aplikasi Flutter dasar, memisahkan halaman utama, serta membuat model dan kartu informasi/menu awal. | `9616c0e` dan commit terkait | Selesai |
| 9–15 November 2026 — Tugas 07 | Menambahkan warna semantik pada menu, merapikan struktur ke `models/` dan `widgets/`, membuat header profil, serta memperbarui SnackBar agar mengikuti warna item dan dapat ditutup. | `8049b21`, `d526f51`, `78c1f1e`, `2aee293`, `200e048`, `89f7e47`, `02d4ab5` | Selesai pada branch dokumentasi saat ini |

Semua commit yang tercantum bertanggal 9–15 November 2026 berdasarkan riwayat lokal. Rincian commit dapat ditinjau dengan `git show <hash>`.

## Keterbatasan Saat Ini

- Konten profil dan item menu masih statis di `lib/menu.dart`.
- Aksi menu hanya menampilkan SnackBar; belum terhubung ke fitur portofolio yang sebenarnya.
- Belum ada integrasi API, autentikasi, penyimpanan lokal, atau sinkronisasi dengan proyek web Django.
- Belum tersedia tangkapan layar atau demo publik khusus aplikasi mobile.

## Informasi Pengembang

- **Nama:** Reshandy Taftazani Aulya
- **NPM:** 2506547651
- **Kelas:** PBP D
- **Mata kuliah:** Pemrograman Berbasis Platform (CSGE602022)
- **Repositori mobile:** [reshandytaftazani/myportofolio_mobile](https://github.com/reshandytaftazani/myportofolio_mobile)
- **Repositori web terkait:** [reshandytaftazani/myportofolio](https://github.com/reshandytaftazani/myportofolio)

