# MyPortfolio Mobile

Aplikasi portofolio pribadi multiplatform yang dibuat dengan Flutter sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer, Universitas Indonesia. Proyek mobile ini melengkapi [portofolio web Django](https://github.com/reshandytaftazani/myportofolio) dengan tampilan ringkas untuk perangkat mobile.

**Status:** Implementasi menu dasar selesai. Dokumentasi dan kelengkapan Tugas 7 masih dalam pengerjaan.

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur Proyek](#struktur-proyek)
- [Menjalankan Secara Lokal](#menjalankan-secara-lokal)
- [Pengujian dan Analisis](#pengujian-dan-analisis)
- [Progres Mingguan](#progres-mingguan)
- [Keterbatasan Saat Ini](#keterbatasan-saat-ini)
- [Kontribusi dan Pelaporan Masalah](#kontribusi-dan-pelaporan-masalah)
- [Refleksi](#refleksi)
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

- Flutter SDK dengan Dart `>=3.13.7 <4.0.0`, mengikuti `environment.sdk: ^3.13.7` pada [pubspec.yaml](pubspec.yaml).
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

- Flutter SDK yang menyertakan Dart `>=3.13.7 <4.0.0`. Periksa dengan `flutter --version`; versi Flutter minimum tidak ditetapkan secara terpisah di `pubspec.yaml`.
- Editor seperti Visual Studio Code dengan ekstensi Flutter atau Android Studio.
- Target untuk menjalankan aplikasi: Chrome, Android Emulator, atau perangkat Android. Target iOS memerlukan macOS dan Xcode.

### Langkah-langkah

Perintah berikut dijalankan dari terminal. Aplikasi saat ini tidak membutuhkan server Django, akun, atau konfigurasi `.env`.

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

### Pemecahan Masalah

| Gejala | Langkah penanganan |
| --- | --- |
| Perintah `flutter` tidak dikenali | Pastikan direktori `bin` Flutter SDK tercantum dalam PATH, lalu buka ulang terminal. |
| `flutter pub get` menolak versi Dart | Periksa `flutter --version` dan gunakan Flutter SDK dengan versi Dart yang memenuhi batas di atas. |
| Perangkat tidak muncul | Jalankan `flutter doctor` dan `flutter devices`; nyalakan emulator atau aktifkan USB debugging pada perangkat Android. |

## Pengujian dan Analisis

Jalankan analisis statis dan pengujian Flutter dari direktori proyek:

```bash
flutter analyze
flutter test
```

`flutter analyze` memeriksa masalah statis sesuai konfigurasi analyzer. `flutter test` menjalankan pengujian yang tersedia di direktori `test/`.

**Kondisi pengujian:** [test/widget_test.dart](test/widget_test.dart) masih berisi tes counter bawaan Flutter yang mengharapkan teks `0`, `1`, dan ikon tambah. Ekspektasi tersebut tidak sesuai dengan halaman portofolio saat ini, sehingga tes itu perlu diperbarui sebelum dapat menjadi bukti kebenaran fitur. Perintah di atas merupakan panduan; bagian ini tidak menyatakan pengujian telah lulus.

Untuk pemeriksaan manual setelah `flutter run`, gunakan skenario berikut. Tabel ini berisi hasil yang diharapkan berdasarkan kode, bukan laporan hasil pengujian yang sudah dilakukan.

| Skenario | Hasil yang diharapkan |
| --- | --- |
| Membuka halaman utama | Profil, NPM `2506547651`, nama, kelas `PBP D`, dan tiga menu terlihat. |
| Menekan masing-masing menu | Pesan `Kamu telah menekan tombol <nama menu>!` muncul dengan warna sesuai kartu. |
| Menekan `TUTUP` | SnackBar ditutup. |
| Menekan menu lain saat SnackBar masih muncul | SnackBar sebelumnya disembunyikan dan pesan item terbaru muncul. |
| Membiarkan SnackBar terbuka | Notifikasi menggunakan durasi konfigurasi dua detik. |
| Mengecilkan ukuran jendela | Periksa keterbacaan profil, kartu identitas, dan label menu; catat ukuran layar jika terjadi overflow. |

## Progres Mingguan

Ringkasan berikut mencatat perubahan yang terlihat dalam riwayat Git proyek. Minggu mengacu pada tanggal commit; catatan ini bukan bukti waktu pengumpulan tugas.

| Periode / kegiatan | Ringkasan pekerjaan | Bukti di riwayat Git | Status |
| --- | --- | --- | --- |
| 9–15 November 2026 — Tutorial 08 | Menyiapkan aplikasi Flutter dasar, memisahkan halaman utama, serta membuat model dan kartu informasi/menu awal. | `9616c0e` dan commit terkait | Selesai |
| 9–15 November 2026 — Tugas 07: implementasi | Menambahkan warna semantik pada menu, merapikan struktur ke `models/` dan `widgets/`, membuat header profil, serta memperbarui SnackBar agar mengikuti warna item dan dapat ditutup. | `8049b21`, `d526f51`, `78c1f1e`, `2aee293`, `200e048`, `89f7e47`, `02d4ab5` | Implementasi selesai |
| 9–15 November 2026 — Tugas 07: dokumentasi | Menyusun ringkasan, setup, progres mingguan, panduan pemeriksaan, dan refleksi. | Draf awal: `83ffefa`; penyempurnaan tercantum pada README ini. | Dalam pengerjaan; disclosure ditunda hingga tahap akhir |

Semua commit yang tercantum bertanggal 9–15 November 2026 berdasarkan riwayat lokal. Rincian commit dapat ditinjau dengan `git show <hash>`.

Pelajaran teknis dari implementasi: model `ItemHomepage.color` membuat warna kartu dan notifikasi memakai sumber data yang sama; pemisahan widget menjaga `menu.dart` berfokus pada komposisi halaman; pemanggilan `hideCurrentSnackBar()` sebelum pesan baru menghindari antrean pesan lama saat menu ditekan berulang. Ini merupakan penjelasan keputusan yang terlihat di kode, bukan klaim hasil pengujian visual.

## Keterbatasan Saat Ini

- Konten profil dan item menu masih statis di `lib/menu.dart`.
- Aksi menu hanya menampilkan SnackBar; belum terhubung ke fitur portofolio yang sebenarnya.
- Belum ada integrasi API, autentikasi, penyimpanan lokal, atau sinkronisasi dengan proyek web Django.
- Belum tersedia tangkapan layar atau demo publik khusus aplikasi mobile.
- Grid menu masih tetap tiga kolom; belum ada penyesuaian jumlah kolom berdasarkan lebar layar. Tampilan pada layar sempit dan skala teks besar perlu diperiksa.

## Kontribusi dan Pelaporan Masalah

Laporkan masalah melalui [GitHub Issues](https://github.com/reshandytaftazani/myportofolio_mobile/issues) dengan langkah reproduksi, hasil yang diharapkan, hasil aktual, versi Flutter/Dart, serta perangkat atau ukuran layar. Sertakan tangkapan layar bila masalah berkaitan dengan tampilan.

Untuk mengusulkan perubahan, buat branch dengan lingkup yang jelas, pertahankan pemisahan model dan widget, lalu ajukan pull request berisi alasan perubahan dan pemeriksaan yang dilakukan. Gunakan pesan commit deskriptif seperti `fix(ui): ...` atau `docs(readme): ...`. Jelaskan kegagalan tes yang masih ada; jangan menyatakan seluruh pemeriksaan lulus tanpa hasil eksekusi.

## Refleksi

### Tugas 7

#### 1. Bagaimana hubungan parent dan child dalam widget tree?

Widget tree menyatakan susunan komponen UI. Pada proyek ini, `MyApp` membangun `MaterialApp`, yang menampilkan `MyHomePage`. Halaman tersebut membangun `Scaffold` dengan `AppBar` dan body berupa `SingleChildScrollView`. Di dalamnya, `Column` menyusun header profil, baris identitas, dan area menu.

Saat layout, parent memberikan batas ukuran kepada child, child menentukan ukuran dalam batas itu, lalu parent menentukan posisi child. Karena itu, lebar yang diminta suatu widget tetap dibatasi ruang yang diberikan parent. Penggunaan `shrinkWrap: true` pada grid membantu menentukan tinggi berdasarkan kontennya dalam halaman yang dapat digulir, tetapi tidak menjamin seluruh teks aman dari overflow. Lihat [penjelasan constraints Flutter](https://docs.flutter.dev/ui/layout/constraints).

#### 2. Widget apa saja yang digunakan dan apa fungsinya?

| Widget | Fungsi dalam proyek |
| --- | --- |
| `MyApp`, `MaterialApp` | Menentukan akar aplikasi, tema, judul, dan halaman awal. |
| `MyHomePage`, `Scaffold`, `AppBar` | Menyusun halaman utama beserta bilah judul. |
| `SingleChildScrollView` | Memungkinkan konten halaman digulir. |
| `Column`, `Row`, `Center`, `Expanded` | Mengatur susunan vertikal, horizontal, pemusatan, dan pembagian ruang. |
| `Padding`, `SizedBox`, `Container` | Mengatur jarak, ukuran, dan dekorasi. |
| `Text`, `Icon`, `CircleAvatar` | Menampilkan teks, simbol, dan avatar inisial. |
| `ProfileHeader`, `InfoCard`, `Card` | Menampilkan profil dan kartu identitas. |
| `GridView.count`, `ItemCard` | Menyusun dan menampilkan tiga menu aksi. |
| `Material`, `InkWell` | Menyediakan permukaan Material dan respons sentuhan kartu. |
| `SnackBar`, `SnackBarAction` | Memberi umpan balik interaksi dan aksi penutup. |

`ItemHomepage` adalah model data, bukan widget. Model ini menyimpan nama, ikon, dan warna item menu.

#### 3. Apa fungsi MaterialApp dan mengapa diletakkan di akar aplikasi?

`MaterialApp` menyediakan konfigurasi bersama untuk aplikasi Material, termasuk tema dan halaman awal. Di `main.dart`, properti `theme` mengatur skema warna dan Material 3, sedangkan `home` menunjuk `MyHomePage`. Menempatkannya dekat akar membuat konfigurasi tersebut tersedia bagi halaman dan komponen turunannya. `MyApp` sendiri tetap merupakan root widget yang diberikan kepada `runApp`. Proyek ini baru memakai satu halaman dan belum mengimplementasikan perpindahan route.

#### 4. Apa perbedaan StatelessWidget dan StatefulWidget?

`StatelessWidget` membangun UI dari konfigurasi dan dependensi yang tersedia tanpa objek `State` tersendiri. Widget ini tetap dapat dibangun ulang ketika parent atau dependensinya berubah. `StatefulWidget` memiliki objek `State` untuk menyimpan data yang berubah sepanjang masa hidup komponen, misalnya input form atau pilihan filter; perubahan melalui `setState` meminta pembangunan ulang UI terkait.

Komponen proyek saat ini memakai `StatelessWidget` karena identitas dan konfigurasi menu bersifat tetap. Menampilkan SnackBar melalui `ScaffoldMessenger` tidak membutuhkan state lokal tambahan pada `ItemCard`; pengelolaan tampilan notifikasinya dilakukan komponen framework.

#### 5. Apa itu BuildContext dan bagaimana digunakan?

`BuildContext` merepresentasikan lokasi widget dalam tree. `Theme.of(context)` memperoleh tema dari ancestor yang sesuai; `MediaQuery.of(context)` digunakan di `InfoCard` untuk membaca ukuran layar; `ScaffoldMessenger.of(context)` digunakan di `ItemCard` untuk menampilkan atau menyembunyikan SnackBar.

Lokasi context menentukan ancestor yang dapat ditemukan. Context milik parent tidak otomatis dapat mengakses widget yang baru dibangun sebagai child di bawahnya. Karena itu, pemanggilan layanan yang bergantung pada ancestor harus menggunakan context di lokasi yang sesuai. Lihat [referensi BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html).

#### 6. Apa perbedaan hot reload dan hot restart serta batasannya?

Hot reload menerapkan perubahan kode dan membangun ulang UI sambil mempertahankan state yang ada. Ini berguna untuk iterasi teks, warna, atau layout. Hot restart memulai ulang aplikasi Flutter dan menginisialisasi ulang state, sehingga sesuai ketika perubahan perlu menjalankan kembali alur awal aplikasi.

Hot reload tidak menjalankan ulang `main()` atau `initState()`. Perubahan pada inisialisasi data yang sudah tersimpan mungkin memerlukan hot restart. Perubahan kode native memerlukan penghentian dan pembangunan ulang aplikasi. Karena mekanismenya berbeda, tampilan yang belum berubah setelah hot reload perlu ditinjau berdasarkan lokasi inisialisasi datanya. Lihat [panduan hot reload Flutter](https://docs.flutter.dev/tools/hot-reload).

## Informasi Pengembang

- **Nama:** Reshandy Taftazani Aulya
- **NPM:** 2506547651
- **Kelas:** PBP D
- **Mata kuliah:** Pemrograman Berbasis Platform (CSGE602022)
- **Repositori mobile:** [reshandytaftazani/myportofolio_mobile](https://github.com/reshandytaftazani/myportofolio_mobile)
- **Repositori web terkait:** [reshandytaftazani/myportofolio](https://github.com/reshandytaftazani/myportofolio)

