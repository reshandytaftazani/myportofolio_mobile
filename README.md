# MyPortfolio Mobile

Aplikasi portofolio pribadi multiplatform yang dibuat dengan Flutter sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer, Universitas Indonesia. Proyek mobile ini melengkapi [portofolio web Django](https://github.com/reshandytaftazani/myportofolio) dengan tampilan ringkas untuk perangkat mobile.

**Status:** Implementasi dan dokumentasi Tugas 8 selesai (lima formulir portofolio tervalidasi, navigasi kartu dan drawer, dialog ringkasan dengan **Edit Isian**, 14 widget test lulus, refleksi, serta AI disclosure).

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur Proyek](#struktur-proyek)
- [Menjalankan Secara Lokal](#menjalankan-secara-lokal)
- [Contoh Alur Demo](#contoh-alur-demo)
- [Pengujian dan Analisis](#pengujian-dan-analisis)
- [Progres Mingguan](#progres-mingguan)
- [Keterbatasan Saat Ini](#keterbatasan-saat-ini)
- [Kontribusi dan Pelaporan Masalah](#kontribusi-dan-pelaporan-masalah)
- [Refleksi](#refleksi)
- [AI Disclosure](#ai-disclosure)
- [Informasi Pengembang](#informasi-pengembang)

## Tentang Proyek

MyPortfolio Mobile menampilkan identitas pemilik portofolio, menu beranda, drawer navigasi, serta lima halaman formulir untuk menambah data portofolio secara lokal. Aplikasi memisahkan model data, validator bersama, halaman form, dan komponen UI agar mudah dikembangkan dan diuji.

Proyek ini merupakan pendamping mobile untuk [MyPortfolio berbasis Django](https://github.com/reshandytaftazani/myportofolio). Pada cakupan Tugas 8, seluruh input divalidasi dan diringkas secara lokal di aplikasi menggunakan dialog ringkasan; integrasi HTTP, autentikasi, dan penyimpanan ke backend Django berada di luar cakupan tugas ini.

## Fitur

- Header profil (`ProfileHeader`) dengan avatar inisial, nama, deskripsi peran, dan status mahasiswa, serta tiga kartu identitas (`InfoCard`) untuk NPM, nama, dan kelas.
- Empat kartu kategori utama di beranda (`MyHomePage`) dalam kisi 2 kolom: **Projects**, **Experiences**, **Education**, dan **Skills**, dengan tinggi kartu mengikuti skala teks perangkat, serta tombol aksi **Logout** pada `AppBar`.
- Halaman bagian portofolio (`PortfolioSectionPage`) yang menyatukan tampilan *empty state* dengan tombol **Tambah** (`FloatingActionButton.extended` dan tombol aksi di tengah layar). Pada bagian **Projects**, tersedia aksi **Tambah Proyek** dan **Tambah Tech Stack**.
- Drawer navigasi bersama (`LeftDrawer`) pada beranda, halaman bagian, dan seluruh halaman form yang disamakan dengan menu beranda (**Home**, **Projects**, **Experiences**, **Education**, dan **Skills**).
- Lima formulir tervalidasi (`StatefulWidget` + `Form` + `GlobalKey<FormState>`) yang diselaraskan dengan model Django:
  - **Tambah Pengalaman** (`ExperienceFormPage`): `title` (wajib, maks 255), `description` (wajib), `company` (opsional, maks 255), `category` (dropdown dengan pilihan Django, default `full-time`), `thumbnail` (opsional, URL HTTP(S) dengan hostname, maks 200), serta `started_at` dan `ended_at` via `showDatePicker()` dengan validasi tanggal akhir tidak mendahului tanggal mulai.
  - **Tambah Pendidikan** (`EducationFormPage`): `school_name` (wajib, maks 255), `period` (wajib, maks 50), `detail` (wajib, maks 255), dan `start_year` (wajib, bilangan bulat positif 4 digit).
  - **Tambah Keahlian** (`SkillFormPage`): `title` (wajib, maks 255), `description` (wajib), `level` (wajib, maks 50), dan `code_snippet` (multiline opsional dengan indentasi tetap terjaga).
  - **Tambah Tech Stack** (`TechStackFormPage`): `name` (wajib, maks 50), `icon_url` (wajib, URL HTTP(S) dengan hostname, maks 200), `filename` (wajib, maks 50), `code_snippet` (multiline wajib dengan indentasi terjaga), dan `order` (bilangan bulat dengan nilai awal `0`).
  - **Tambah Proyek** (`ProjectFormPage`): `title` (wajib, maks 255), `description` (wajib), `category` (dropdown dengan pilihan Django, default `Other`), `project_url` (opsional, URL HTTP(S), maks 200), `project_image_url` (opsional, URL HTTP(S), maks 500), dan switch `is_featured` (default `false`).
- Dialog ringkasan bersama (`FormSummaryDialog`) yang hanya muncul ketika `FormState.validate()` lolos, menampilkan seluruh field termasuk yang kosong (`-`), dapat digulir pada layar sempit, dan menyediakan dua aksi:
  - **Edit Isian**: menutup dialog sambil mempertahankan semua nilai (termasuk indentasi cuplikan kode) agar pengguna dapat memperbaiki isian.
  - **Selesai**: menutup dialog dan mereset form ke kondisi awal.

## Teknologi

- Flutter SDK dengan Dart `^3.13.7` pada [pubspec.yaml](pubspec.yaml).
- `material_ui: ^1.11.1` dan tema Material 3 untuk komponen antarmuka.
- `flutter_lints: ^6.0.0` untuk analisis statis.
- `flutter_test` untuk pengujian widget.

Versi Flutter/Dart yang terpasang di mesin pengembang dapat diperiksa dengan `flutter --version`.

## Struktur Proyek

```text
lib/
├── main.dart                         # Titik masuk dan konfigurasi MaterialApp
├── forms/
│   └── form_validators.dart          # Validator bersama (URL HTTP(S), teks wajib, panjang)
├── models/
│   ├── education.dart                # Model data Pendidikan
│   ├── experience.dart               # Model data Pengalaman
│   ├── item_homepage.dart            # Model item kategori menu beranda & drawer
│   ├── project.dart                  # Model data Proyek
│   ├── skill.dart                    # Model data Keahlian
│   └── tech_stack.dart               # Model data Tech Stack
├── screens/
│   ├── education_form.dart           # Halaman form Tambah Pendidikan
│   ├── experience_form.dart          # Halaman form Tambah Pengalaman
│   ├── menu.dart                     # Halaman utama (MyHomePage)
│   ├── portfolio_section_page.dart   # Halaman bagian portofolio & konfigurasi menu
│   ├── project_form.dart             # Halaman form Tambah Proyek
│   ├── skill_form.dart               # Halaman form Tambah Keahlian
│   └── tech_stack_form.dart          # Halaman form Tambah Tech Stack
└── widgets/
    ├── form_summary_dialog.dart      # Dialog ringkasan bersama (Edit Isian & Selesai)
    ├── info_card.dart                # Kartu informasi identitas
    ├── left_drawer.dart              # Drawer navigasi bersama
    ├── profile_header.dart           # Header profil
    └── project_card.dart             # Kartu aksi menu (ItemCard)
test/
└── widget_test.dart                  # 14 widget test navigasi, validasi, dialog, dan layout
```

## Menjalankan Secara Lokal

### Prasyarat

- Flutter SDK yang menyertakan Dart `^3.13.7`. Periksa dengan `flutter --version`.
- Editor seperti Visual Studio Code dengan ekstensi Flutter atau Android Studio.
- Target eksekusi: Google Chrome, Android Emulator, atau perangkat Android (target iOS memerlukan macOS dan Xcode).

### Langkah-langkah

Perintah berikut dijalankan dari direktori akar proyek. Aplikasi belum membutuhkan server Django, akun, atau berkas `.env`.

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

   Untuk menjalankan langsung di Chrome, gunakan:

   ```bash
   flutter run -d chrome
   ```

   Daftar target yang terdeteksi dapat diperiksa dengan `flutter devices`.

### Pemecahan Masalah

| Gejala | Langkah penanganan |
| --- | --- |
| Perintah `flutter` tidak dikenali | Pastikan direktori `bin` Flutter SDK tercantum dalam `PATH`, lalu buka ulang terminal. |
| `flutter pub get` menolak versi Dart | Periksa `flutter --version` dan gunakan Flutter SDK dengan versi Dart yang memenuhi batas pada `pubspec.yaml`. |
| Perangkat tidak muncul | Jalankan `flutter doctor` dan `flutter devices`; nyalakan emulator atau aktifkan USB debugging pada perangkat Android. |

## Contoh Alur Demo

Alur berikut dapat digunakan untuk mendemokan fitur utama dari beranda/drawer hingga dialog ringkasan:

1. **Buka form dari kartu atau drawer**: Pada beranda, ketuk kartu **Experiences** (atau buka ikon menu kiri atas untuk membuka `LeftDrawer` lalu pilih **Experiences**), kemudian tekan tombol **Tambah Pengalaman**.
2. **Uji validasi gagal**: Langsung tekan **Simpan** tanpa mengisi field wajib, lalu coba masukkan URL thumbnail tidak valid (mis. `not-a-url`) atau pilih `ended_at` lebih awal dari `started_at`. Pesan error muncul di kolom terkait dan dialog tidak terbuka.
3. **Isi data valid dan simpan**: Lengkapi `title`, `description`, `company` (opsional), pilih `category`, masukkan URL thumbnail valid (`https://...`), dan pilih rentang tanggal yang benar. Gulir ke bawah lalu tekan **Simpan**.
4. **Periksa dialog ringkasan dan Edit Isian**: Dialog menampilkan semua field. Tekan **Edit Isian** untuk menutup dialog tanpa menghapus nilai di form, lalu ubah salah satu field dan tekan **Simpan** lagi.
5. **Selesai dan kembali ke beranda**: Tekan **Selesai** pada dialog untuk mereset seluruh field form. Gunakan tombol **Back** (jika masuk lewat kartu) atau buka drawer lalu pilih **Home** untuk kembali ke beranda tanpa menumpuk rute.

Pola yang sama berlaku untuk **Projects** (**Tambah Proyek** & **Tambah Tech Stack**), **Education** (**Tambah Pendidikan**), dan **Skills** (**Tambah Keahlian**).

## Pengujian dan Analisis

Jalankan analisis statis dan pengujian widget dari direktori proyek:

```bash
flutter analyze
flutter test
```

### Hasil Pengujian Aktual (Tugas 8)

- **`flutter analyze`**: `No issues found!` (bersih tanpa error, warning, maupun lint issue).
- **`flutter test`**: **14/14 tes di [test/widget_test.dart](test/widget_test.dart) lulus**, mencakup:
  - Navigasi kartu beranda, halaman bagian (`Projects`, `Experiences`, `Education`, `Skills`), dan drawer menuju seluruh 5 form (`Proyek`, `Pengalaman`, `Pendidikan`, `Keahlian`, `Tech Stack`), termasuk perilaku `Back` dan `Home`.
  - Validasi input wajib kosong/spasi, batas panjang karakter, URL HTTP(S), rentang tanggal Pengalaman, tahun 4 digit Pendidikan, dan urutan bilangan bulat Tech Stack.
  - Dialog ringkasan: tampil hanya saat valid, `Edit Isian` mempertahankan seluruh nilai (termasuk indentasi `code_snippet`), dan `Selesai` mereset form.
  - Keterjangkauan scroll pada lebar ponsel dengan keyboard terbuka serta dialog cuplikan kode panjang pada layar sempit.

### Pemeriksaan Manual (Chrome / Perangkat)

| Skenario | Hasil yang diharapkan |
| --- | --- |
| Kartu aksi dan drawer pada lima form | Kedua jalur membuka form yang sesuai; **Home** dan **Back** kembali ke beranda tanpa menumpuk rute. |
| Input wajib, panjang, URL, tanggal, dan angka | Pesan kesalahan tampil di kolom terkait dan dialog ringkasan tetap tertutup. |
| Dialog ringkasan | Seluruh nilai valid tampil; **Edit Isian** mempertahankan isian dan **Selesai** mereset form. |
| Layar ponsel (`390x844`) dan keyboard | Drawer, form, dan dialog dapat digulir hingga aksi terakhir (`Simpan`, `Edit Isian`, `Selesai`). |

## Progres Mingguan

Ringkasan berikut mencatat progres implementasi pada riwayat Git proyek:

| Periode / kegiatan | Ringkasan pekerjaan | Bukti di riwayat Git | Status |
| --- | --- | --- | --- |
| 9–15 November 2026 — Tutorial 08 & Tugas 07 | Menyiapkan aplikasi dasar, header profil, kartu identitas, 6 menu beranda berwarna, SnackBar kontekstual, serta dokumentasi/refleksi/AI disclosure Tugas 7. | `9616c0e`, `8049b21`–`02d4ab5`, `83ffefa`–`3875f98` | Selesai |
| 17 November 2026 — Tutorial 09 | Menambahkan `LeftDrawer`, form awal Proyek, dialog ringkasan awal, navigasi dari kartu/drawer, serta refaktor struktur `models/`, `screens/`, `widgets/`. | `22d017c`, `0763f8f`, `33a638d`, `e7d61c0`, `0e9725f` | Selesai |
| 20–21 November 2026 — Tugas 08 Stage 1 (Pengalaman & Dialog) | Membuat model & form `Experience` dengan validasi URL/tanggal, `FormSummaryDialog` dengan aksi **Edit Isian** & **Selesai**, integrasi kartu/drawer, dan widget test. | `c3b9ffc`, `798f680`, `e75aaad`, `217c8bc`, `290c9d8`, `0b623b6` | Selesai |
| 21 November 2026 — Tugas 08 Stage 2 (Pendidikan & Keahlian) | Membuat model & form `Education` (validasi tahun 4 digit) dan `Skill` (cuplikan kode multiline), integrasi kartu/drawer, dan widget test. | `b1bebb4`, `49c97d8`, `947507f`, `a41dc2d`, `ecd9026` | Selesai |
| 21 November 2026 — Tugas 08 Stage 3 (Tech Stack & Validator) | Membuat model & form `TechStack`, mengekstrak `form_validators.dart` bersama, integrasi kartu/drawer, dan uji ringkasan multiline. | `16a2790`, `af4b215`, `4a0ca52`, `056cd2a` | Selesai |
| 21 November 2026 — Tugas 08 Stage 4 (Penyelarasan Proyek) | Menyelaraskan `Project` dan `ProjectFormPage` dengan model Django (`project_url`, `project_image_url`, `is_featured`), memakai `FormSummaryDialog` bersama, dan memperbarui tes regresi. | `395afcd`, `2522436`, `680e632`, `8bb6ea8` | Selesai |
| 21 November 2026 — Tugas 08 Stage 5 (Verifikasi & Dokumentasi) | Verifikasi akhir (`flutter analyze` bersih, 14/14 `flutter test` lulus, pemeriksaan Chrome/perangkat) serta pembaruan panduan, struktur berkas, hasil uji, dan progres di `README.md`. | Branch `docs/tugas-8-final-verification-and-documentation`, `6199929` | Selesai |
| 21 November 2026 — Penyederhanaan Menu & Drawer | Menyederhanakan 10 kartu menu beranda menjadi 4 kategori (`Projects`, `Experiences`, `Education`, `Skills`), memindahkan `Logout` ke `AppBar`, menambahkan `PortfolioSectionPage`, dan menyamakan `LeftDrawer`. | `11224a0` | Selesai |

## Keterbatasan Saat Ini

- Halaman bagian (`PortfolioSectionPage`) masih menampilkan *empty state* tanpa daftar data tersimpan, dan tombol **Logout** pada `AppBar` masih bersifat demonstrasi SnackBar.
- Data formulir baru divalidasi dan diringkas secara lokal di dialog; belum ada integrasi HTTP, autentikasi sesi, maupun sinkronisasi database ke backend Django.
- Konten profil dan daftar menu beranda masih didefinisikan secara statis di `lib/screens/menu.dart`.

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
| `LayoutBuilder`, `GridView.count`, `ItemCard` | Menyesuaikan jumlah kolom terhadap ruang tersedia dan menampilkan enam menu aksi. |
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

### Tugas 8

#### 1. Bagaimana perbedaan `Navigator.push`, `Navigator.pushReplacement`, dan `Navigator.pop`, serta bagaimana alur navigasi `Home` diterapkan?

- `Navigator.push` menambahkan route baru di atas stack navigasi sehingga tombol **Back** dapat kembali ke halaman sebelumnya. Pada [project_card.dart](lib/widgets/project_card.dart), mengetuk kartu aksi (misalnya **Tambah Pengalaman**) memanggil `Navigator.push(context, MaterialPageRoute(...))`. Di [left_drawer.dart](lib/widgets/left_drawer.dart), membuka form dari beranda (`isHome == true`) juga memakai `Navigator.push`.
- `Navigator.pushReplacement` mengganti route yang sedang aktif di puncak stack dengan route baru tanpa menambah tumpukan halaman form. Di `LeftDrawer._navigateToForm`, saat pengguna berpindah dari satu form ke form lain (`isHome == false`), aplikasi memanggil `Navigator.pushReplacement`, sehingga menekan **Back** tidak melewati riwayat form sebelumnya satu per satu.
- `Navigator.pop` menutup route teratas pada stack—digunakan di `LeftDrawer` untuk menutup drawer sebelum berpindah halaman, dan di [form_summary_dialog.dart](lib/widgets/form_summary_dialog.dart) untuk menutup `AlertDialog` sambil mengembalikan nilai `false` (**Edit Isian**) atau `true` (**Selesai**).
- Untuk opsi **Home**, `LeftDrawer._navigateToHome` menutup drawer dengan `Navigator.pop(context)`. Jika sudah berada di `MyHomePage` (`isHome == true`), navigasi berhenti agar tidak membuat salinan beranda. Jika sedang berada di halaman form, aplikasi memanggil `Navigator.pushAndRemoveUntil(..., (route) => false)` untuk membersihkan stack dan kembali ke `MyHomePage` sebagai satu-satunya route.

#### 2. Bagaimana struktur `Scaffold`, `AppBar`, dan `Drawer` menyusun halaman form serta memanfaatkan tema aplikasi?

Setiap halaman form (misalnya `ExperienceFormPage` di [experience_form.dart](lib/screens/experience_form.dart)) dibungkus oleh `Scaffold` dengan `AppBar`, `drawer: const LeftDrawer()`, dan `body` berupa `Form`. `AppBar` menampilkan judul halaman berwarna putih tebal, `iconTheme` putih, serta `backgroundColor: Theme.of(context).colorScheme.primary`.

Skema warna utama (`indigo`) dan sekunder (`amber[700]`) dikonfigurasi terpusat pada `ThemeData(colorScheme: ColorScheme.fromSeed(...), useMaterial3: true)` di `MyApp` ([main.dart](lib/main.dart)). Tombol **Simpan** (`ElevatedButton`) pada seluruh halaman form juga mengambil `colorScheme.primary` dari `Theme.of(context).colorScheme`, sementara `LeftDrawer` dipakai ulang secara konsisten di `MyHomePage` dan kelima halaman form.

#### 3. Widget jarak dan pengguliran apa yang digunakan agar halaman tetap nyaman pada ruang terbatas dan saat keyboard terbuka?

- Pada halaman form (seperti [experience_form.dart](lib/screens/experience_form.dart)), `Column` input dibungkus `SingleChildScrollView(padding: const EdgeInsets.all(16.0), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag)`. Saat viewport sempit (misalnya lebar ponsel `390x844`) atau keyboard terbuka, pengguna tetap dapat menggulir sampai tombol **Simpan** dan menutup keyboard dengan menggeser layar.
- Jarak antar-kolom form diatur menggunakan `const SizedBox(height: 16.0)` (dan `24.0` sebelum tombol **Simpan**, ditambah `16.0` di bawah tombol).
- Pada `LeftDrawer` ([left_drawer.dart](lib/widgets/left_drawer.dart)), daftar menu memakai `ListView` dan isi `DrawerHeader` dibungkus `SingleChildScrollView` agar tidak overflow pada layar pendek atau skala teks besar.
- Pada `FormSummaryDialog` ([form_summary_dialog.dart](lib/widgets/form_summary_dialog.dart)), isi ringkasan dibungkus `SingleChildScrollView` di dalam `SizedBox(width: double.maxFinite)` supaya cuplikan kode panjang tetap dapat digulir tanpa mendorong aksi **Edit Isian** dan **Selesai** keluar layar.

#### 4. Bagaimana peran `GlobalKey<FormState>`, `validator`, dan `validate()` dalam validasi form, beserta satu contoh input yang ditolak?

- Setiap halaman form menyimpan `final _formKey = GlobalKey<FormState>()` yang dipasang ke widget `Form(key: _formKey, ...)`. `GlobalKey<FormState>` memberi akses ke `FormState` dari handler tombol **Simpan** (`_submitForm`).
- Setiap `TextFormField` mendaftarkan fungsi `validator` yang mengembalikan `String` pesan kesalahan jika input tidak valid, atau `null` jika valid. Aturan URL HTTP(S) bersama diekstrak ke `validateHttpUrl` di [form_validators.dart](lib/forms/form_validators.dart) untuk dipakai ulang di `ExperienceFormPage`, `TechStackFormPage`, dan `ProjectFormPage`.
- Saat **Simpan** ditekan, `_formKey.currentState!.validate()` memicu seluruh `validator` pada form sekaligus. Jika ada field yang tidak valid, `validate()` mengembalikan `false`, pesan kesalahan muncul di kolom terkait, dan `showFormSummaryDialog(...)` tidak dipanggil.
- **Contoh input yang ditolak:** Pada `ExperienceFormPage`, mengisi `URL Thumbnail` dengan `not-a-url` (atau tanpa skema `http`/`https` dan hostname) ditolak oleh `validateHttpUrl` dengan pesan `'Gunakan URL HTTP/HTTPS yang valid dengan hostname.'` sehingga dialog ringkasan tidak terbuka. Selain itu, memilih `Tanggal Selesai` lebih awal dari `Tanggal Mulai` juga ditolak dengan pesan `'Tanggal selesai harus sama dengan atau setelah tanggal mulai.'`.

## AI Disclosure

Dalam pengerjaan MyPortfolio Mobile, saya menggunakan bantuan AI sebagai pemandu dalam implementasi dan validator terhadap kesesuaian spesifikasi, pemahaman masalah teknis, evaluasi alternatif pengembangan Flutter, serta penyusunan dan revisi dokumentasi berdasarkan arahan saya. Saran AI diperlakukan sebagai draf yang perlu diperiksa terhadap kode, kebutuhan tugas, dan hasil pengujian. Disclosure ini berfokus pada aplikasi mobile dalam repositori ini.

### Alat yang Digunakan

Antigravity (powered by Google Gemini), Claude.ai, gemini.google, dan OpenAI Codex digunakan dalam eksplorasi ekosistem proyek, sesuai catatan penggunaan pengembang. Untuk sesi dokumentasi mobile sebelumnya, bantuan diberikan melalui OpenAI Codex, sedangkan pada tahap pemanduan implementasi formulir, validasi, dan pembaruan dokumentasi lanjutan, bantuan diberikan melalui Antigravity (powered by Google Gemini). Daftar ini tidak menyatakan bahwa setiap alat digunakan pada setiap bagian tugas. Persentase kontribusi tidak dicantumkan karena tidak ada pengukuran yang mendukungnya.

### Strategi Prompting

- **Memberikan konteks masalah:** Menyertakan pesan error, potongan kode, perilaku aktual, dan hasil yang diharapkan.
- **Membatasi ruang lingkup:** Memberikan rubrik tugas, repositori referensi Django (`myportofolio`), dan batasan Flutter dasar agar saran tetap sesuai tahap pembelajaran serta tidak melampaui cakupan tugas (lokal tanpa integrasi HTTP/autentikasi pada tahap ini). Pada dokumentasi mobile, penulisan diarahkan untuk mengikuti isi `lib/`, konfigurasi dependensi, dan riwayat commit.
- **Memeriksa keluaran secara bertahap:** Meminta pencocokan dokumentasi dengan rencana tugas, mempertanyakan klaim yang tidak didukung berkas, dan meminta revisi sebelum perubahan dianggap siap.
- **Memisahkan penulisan dan persetujuan:** Dokumentasi, refleksi, dan disclosure ditinjau manual sebelum di-commit; pengerjaan diminta **tanpa commit terlebih dahulu** hingga hasilnya diperiksa dan disetujui pengembang.

### Bagian Spesifik yang Dibantu oleh AI

- **Panduan pengembangan selanjutnya:** AI membantu memberikan arahan mengenai langkah pengembangan, urutan pengerjaan, dan bagian yang masih perlu diperbaiki berdasarkan kondisi proyek serta batasan materi Flutter dasar.
- **Saran peningkatan untuk target nilai 4:** AI membantu mencocokkan kondisi proyek dengan rubrik dan mengidentifikasi peningkatan yang relevan, seperti modularisasi widget, penguatan identitas profil, interaktivitas SnackBar, serta kelengkapan dokumentasi dan progres mingguan. Saran tersebut menjadi bahan pertimbangan pengembang; pencapaian nilai tetap bergantung pada hasil implementasi, verifikasi, dan penilaian pengajar.
- **Pemandu implementasi dan validator:** AI berperan sebagai pemandu langkah demi langkah saat menerapkan model, formulir (`Experience`, `Education`, `Skill`, `TechStack`, dan penyelarasan `Project`), validator URL bersama (`lib/forms/form_validators.dart`), serta dialog ringkasan bersama (`FormSummaryDialog`), sekaligus membantu memvalidasi konsistensi kode dan skenario pengujian (`flutter analyze` dan `flutter test`) terhadap acuan model Django dan rencana kerja.

### Keterbatasan AI dan Koreksi yang Dilakukan

Koreksi manual dalam catatan ini merujuk pada peninjauan, keputusan, dan arahan pengembang. Penerapan revisi dokumentasi juga menggunakan bantuan AI; hal ini dibedakan dari klaim bahwa seluruh penyuntingan dilakukan sendiri oleh pengembang.

1. **Klaim faktual dapat terlihat meyakinkan meskipun tidak didukung bukti.**
   - **Keterbatasan AI:** Draf sempat mempertahankan badge MIT dan menambahkan tautan `LICENSE`, meskipun berkas lisensi tidak ditemukan. Pola README yang umum digunakan keliru diperlakukan sebagai fakta proyek.
   - **Koreksi pengembang:** Saya mempertanyakan keberadaan lisensi dan meminta agar isi dokumentasi mengikuti berkas yang benar-benar ada. Klaim MIT kemudian dihapus. Pelajarannya, kelengkapan dokumentasi harus dibangun dari bukti, bukan asumsi atau kebiasaan templat.

2. **Informasi versi SDK perlu diperiksa terhadap konfigurasi proyek.**
   - **Keterbatasan AI:** Draf sempat menampilkan badge versi Flutter dan Dart tanpa membuktikan versi lingkungan yang digunakan. Batas versi Dart dalam konfigurasi juga tidak otomatis menetapkan satu versi minimum Flutter tertentu.
   - **Koreksi dokumentasi:** Badge versi spesifik dihapus dan prasyarat diselaraskan dengan `environment.sdk: ^3.13.7` pada `pubspec.yaml`. Pembaca diarahkan memeriksa `flutter --version` agar kompatibilitas ditentukan dari lingkungan yang benar-benar digunakan.

3. **Selesainya kode dapat keliru dianggap sebagai selesainya seluruh tugas.**
   - **Keterbatasan AI:** Draf progres menyatakan Tugas 07 selesai saat refleksi dan disclosure belum lengkap. Label status yang terlalu luas mengaburkan pekerjaan yang masih tersisa.
   - **Koreksi pengembang:** Saya meminta pemeriksaan ulang terhadap rencana tugas. Status implementasi dan dokumentasi kemudian diperjelas, dan commit terpisah dibuat sesuai tahapannya. Status akhir tetap perlu mengikuti pemeriksaan kelengkapan, bukan hanya keberadaan kode.

4. **Saran perintah pengujian tidak sama dengan bukti pengujian berhasil.**
   - **Keterbatasan AI:** Draf awal mencantumkan `flutter test` tanpa menjelaskan bahwa `test/widget_test.dart` masih menguji counter bawaan. Tes tersebut belum mewakili fitur portofolio. Demikian pula, hasil analyzer yang bersih tidak membuktikan warna, layout, atau interaksi sudah benar secara visual.
   - **Koreksi dokumentasi:** Kondisi tes dicatat secara eksplisit pada tahap awal dan kemudian diperbarui dengan hasil aktual setelah 14 widget test ditulis dan dijalankan (`flutter analyze` bersih dan `flutter test` lulus).

5. **Analisis kode tidak cukup untuk menjamin responsivitas antarmuka.**
   - **Keterbatasan AI:** `SingleChildScrollView` dan lebar kartu berbasis `MediaQuery` dapat membantu layout, tetapi tidak menjamin bebas overflow. Grid awal memakai tiga kolom tetap; penambahan menu kemudian memakai dua atau tiga kolom sesuai ruang tersedia. Lebar kartu tetap perlu memperhitungkan padding, margin, serta ukuran teks.
   - **Koreksi dokumentasi:** Klaim jaminan bebas overflow diganti dengan penjelasan keterbatasan dan skenario pemeriksaan pada layar sempit serta skala teks besar.

6. **Verifikasi otomatis browser bergantung pada konfigurasi debugging lokal.**
   - **Keterbatasan AI:** Saat menjalankan pemeriksaan Chrome melalui subagent browser pada `http://localhost:8080`, koneksi gagal karena `DevToolsActivePort` belum tersedia (`chrome://inspect/#remote-debugging` belum diaktifkan).
   - **Koreksi pengembang:** Pengembang menjalankan pemeriksaan manual secara langsung di Chrome/perangkat untuk memastikan kelima form, navigasi drawer/kartu, serta tombol **Simpan** saat keyboard terbuka berfungsi dengan baik sebelum menyetujui tahap verifikasi selesai.

Catatan interaksi dan jejak perubahan yang dapat ditelusuri mencakup permintaan revisi README, koreksi klaim MIT, pemeriksaan rencana tugas, dan permintaan commit terpisah (antara lain `40472fe`, `3875f98`, serta rangkaian commit lanjutan `c3b9ffc`–`8bb6ea8`, `8f1118b`, dan `3cae34b`); commit menunjukkan perubahan berkas, bukan transkrip percakapan. Ekspor chat lengkap belum disertakan. Pengembang tetap bertanggung jawab memeriksa ketepatan isi, memahami jawaban reflektif, dan memvalidasi perilaku aplikasi sebelum pengumpulan.

## Informasi Pengembang

- **Nama:** Reshandy Taftazani Aulya
- **NPM:** 2506547651
- **Kelas:** PBP D
- **Mata kuliah:** Pemrograman Berbasis Platform (CSGE602022)
- **Repositori mobile:** [reshandytaftazani/myportofolio_mobile](https://github.com/reshandytaftazani/myportofolio_mobile)
- **Repositori web terkait:** [reshandytaftazani/myportofolio](https://github.com/reshandytaftazani/myportofolio)

