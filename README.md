# MyPortfolio Mobile

[![CI](https://github.com/reshandytaftazani/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/reshandytaftazani/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi portofolio pribadi multiplatform yang dibuat dengan Flutter sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer, Universitas Indonesia. Proyek mobile ini melengkapi [portofolio web Django](https://github.com/reshandytaftazani/myportofolio) (live di [PWS](https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id)) dengan tampilan ringkas untuk perangkat mobile.

**Status:** Integrasi penuh Django REST Framework (DRF) & autentikasi token untuk seluruh 5 entitas portofolio (**Projects**, **Tech Stack**, **Experiences**, **Education**, dan **Skills** — `GET`, `POST`, dan `DELETE` terautentikasi) telah selesai, terhubung default ke backend PWS, serta didukung pipeline CI/CD GitHub Actions (`very_good_workflows` + build artefak `app-release-apk`). Verifikasi kualitas bersih (`dart format` `0 changed`, `flutter analyze` bersih, **106/106** tes lulus).

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

MyPortfolio Mobile menampilkan identitas pemilik portofolio, menu beranda, drawer navigasi, daftar dan detail item portofolio, autentikasi token DRF, lima halaman formulir terautentikasi untuk menambah data, serta aksi hapus terautentikasi pada halaman detail. Aplikasi memisahkan model data (`json_serializable`), layanan jaringan (`ApiClient`, `AuthState`, `PortfolioRefreshNotifier`), validator bersama, helper aksi terautentikasi, halaman form, dan komponen UI agar mudah dikembangkan dan diuji.

Proyek ini merupakan pendamping mobile untuk [MyPortfolio berbasis Django](https://github.com/reshandytaftazani/myportofolio) yang di-deploy pada PWS di [https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id](https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id). Seluruh 5 entitas portofolio (**Projects**, **Tech Stack**, **Experiences**, **Education**, dan **Skills**) telah terintegrasi secara *live* dengan backend Django REST Framework untuk:

- Mengambil daftar publik secara asinkron (`GET /api/v1/projects/`, `/api/v1/techstacks/`, `/api/v1/experiences/`, `/api/v1/education/`, dan `/api/v1/skills/`).
- Melakukan login dan logout berbasis token DRF (`POST /api/v1/auth/token/` & `POST /api/v1/auth/logout/`).
- Menambahkan data baru secara terautentikasi (`POST`) melalui ke-5 halaman formulir dengan penanganan `401 Unauthorized` otomatis.
- Menghapus data secara terautentikasi (`DELETE /api/v1/<resource>/<id>/`) dengan dialog konfirmasi langsung dari halaman detail (`PortfolioDetailPage`).

Data dummy lokal (`DummyPortfolioData`) tidak lagi digunakan pada tampilan runtime standar dan hanya dipertahankan sebagai fixture deterministik opsional untuk pengujian widget yang menginjeksi `PortfolioDataSource`.

## Fitur

- Header profil (`ProfileHeader`) dengan avatar inisial, nama, deskripsi peran, dan status mahasiswa, serta tiga kartu identitas (`InfoCard`) dengan tinggi seragam untuk NPM, nama, dan kelas.
- Empat kartu kategori utama di beranda (`MyHomePage`) dalam kisi 2 kolom: **Projects**, **Experiences**, **Education**, dan **Skills**, dengan tinggi kartu mengikuti skala teks perangkat, tombol aksi **Login** / **Logout** pada `AppBar` yang terhubung ke `AuthState`, serta pembatas pratinjau ponsel (`_WebPhoneViewport`) saat mode debug di Web.
- Integrasi backend DRF penuh & autentikasi token (*in-memory* sesuai Tutorial 10):
  - `ApiClient` dengan dukungan `GET`, `POST`, dan `DELETE` terautentikasi untuk seluruh 5 entitas (`Project`, `Experience`, `Education`, `Skill`, `TechStack`), timeout default 15 detik, parsing pesan error DRF yang aman (menghindari dump HTML mentah), serta lifecycle penutupan `http.Client` melalui `Provider.dispose` di `MyApp`.
  - `AuthState` (`ChangeNotifier`) yang menyimpan token DRF di memori selama sesi berjalan, `LoginScreen` untuk autentikasi pengguna, route guard `ensureLoggedIn(context)` pada seluruh aksi **Tambah** & **Hapus**, serta helper bersama `runAuthenticatedApiAction` (`lib/utils/authenticated_action_helper.dart`) yang menangani `401 Unauthorized` dengan membersihkan sesi, menampilkan `SnackBar`, dan mengarahkan login ulang tanpa menghilangkan isian form.
  - Widget generik `PortfolioAsyncListView<T>` (dan wrapper kompatibilitas `ProjectListView`) yang menginisialisasi `Future` di `initState()`, menyediakan *pull-to-refresh* tanpa menghilangkan daftar saat memuat ulang, penanganan state loading/empty/error ramah (`formatApiError`) dengan tombol **Coba Lagi**, serta sinkronisasi lintas layar melalui `PortfolioRefreshNotifier` (dan `ProjectRefreshNotifier`) saat menambah atau menghapus data.
- Halaman bagian portofolio (`PortfolioSectionPage`) yang menghubungkan **Projects**, tab **Tech Stack**, **Experiences**, **Education**, dan **Skills** ke daftar *live* API (`primaryBody` & `secondaryBody`) dengan tombol **Tambah** (`FloatingActionButton.extended`) yang menyesuaikan tab aktif dan dilindungi autentikasi (`requiresAuth: true`).
- Lima widget kartu daftar (`ProjectItemCard`, `TechStackCard`, `ExperienceCard`, `EducationCard`, dan `SkillCard`) yang dapat ditekan untuk membuka halaman detail lengkap (`PortfolioDetailPage`) berisi seluruh atribut model, *code snippet* monospace penuh (`CodeSnippetBox`), tanggal lengkap, status `Featured`/`Ongoing`, URL proyek yang dapat dibuka (`url_launcher`), metadata *star*, serta tombol aksi **Hapus** terautentikasi di `AppBar` (untuk item dengan `id` non-null) lengkap dengan dialog konfirmasi dan auto-refresh daftar.
- Dukungan pemuatan gambar dan ikon SVG jaringan melalui `PortfolioNetworkImage` (`flutter_svg` dengan loader IO/stub dan utilitas bersama `portfolio_svg_utils.dart`), dekode gambar terukur (`ResizeImage`) pada kartu, serta tata letak responsif pada layar sempit dan skala teks besar di `SkillCard` dan `PortfolioDetailPage`.
- Resolver rute kategori web (`/section/projects`, `/section/experiences`, `/section/education`, `/section/skills`) melalui `onGenerateInitialRoutes`, `onGenerateRoute`, dan `onUnknownRoute` di `main.dart` serta penggunaan ulang rute kategori di `LeftDrawer` via `PortfolioRouteObserver`.
- Proteksi draf formulir (`FormDraftStateMixin`, `PortfolioFormScaffold`, `FormDraftPopScope`, dan `draft_confirm_dialog.dart`) pada seluruh 5 form yang meminta konfirmasi sebelum membuang perubahan yang belum disimpan, sekaligus menutup drawer terlebih dahulu saat tombol **Back** ditekan ketika drawer terbuka.
- Serialisasi JSON tergenerasi (`@JsonSerializable(fieldRename: FieldRename.snake)` + `build_runner`) dengan `@JsonKey(..., includeToJson: false)` pada `id` (agar `POST` tidak mengirim ID buatan klien) beserta `copyWith`, `==`, dan `hashCode` pada seluruh 5 model (`Education`, `Experience`, `Project`, `Skill`, `TechStack`) yang diselaraskan dengan `main/serializers.py` pada backend Django.
- Theme Material 3 terpusat di `main.dart` (`AppBarTheme`, `FilledButtonThemeData`, `InputDecorationTheme`, dan `CodeSnippetTheme` extension) dengan konfigurasi keamanan jaringan Android yang membatasi *cleartext HTTP* hanya pada host lokal debug (`10.0.2.2`, `localhost`, `127.0.0.1`).
- Drawer navigasi bersama (`LeftDrawer`) pada beranda, halaman bagian, dan seluruh halaman form dengan menu **Home**, **Projects**, **Experiences**, **Education**, **Skills**, submenu lipat **Tambah Data** (`ExpansionTile`) untuk kelima formulir yang dilindungi `ensureLoggedIn` dan otomatis menyegarkan daftar terkait, serta **Login** / **Logout**.
- Lima formulir tervalidasi (`StatefulWidget` + `Form` + `FormDraftStateMixin`) yang seluruhnya mengirim `POST` terautentikasi ke DRF, mengunci field saat submit, menangani `401` dengan re-login, dan mengembalikan `true` saat keluar untuk memicu refresh daftar:
  - **Tambah Pengalaman** (`ExperienceFormPage` → `POST /api/v1/experiences/`): `title` (wajib, maks 255), `description` (wajib), `company` (opsional, maks 255), `category` (dropdown pilihan Django, default `full-time`), `thumbnail` (opsional, URL HTTP(S) dengan hostname, maks 200), serta `started_at` dan `ended_at` via `showDatePicker()` (diformat `YYYY-MM-DD` menggunakan `formatIsoDate`) dengan validasi tanggal akhir tidak mendahului tanggal mulai.
  - **Tambah Pendidikan** (`EducationFormPage` → `POST /api/v1/education/`): `school_name` (wajib, maks 255), `period` (wajib, maks 50), `detail` (wajib, maks 255), dan `start_year` (wajib, bilangan bulat positif 4 digit).
  - **Tambah Keahlian** (`SkillFormPage` → `POST /api/v1/skills/`): `title` (wajib, maks 255), `description` (wajib), `level` (wajib, maks 50), dan `code_snippet` (multiline opsional dengan indentasi tetap terjaga).
  - **Tambah Tech Stack** (`TechStackFormPage` → `POST /api/v1/techstacks/`): `name` (wajib, maks 50), `icon_url` (wajib, URL HTTP(S) dengan hostname, maks 200), `filename` (wajib, maks 50), `code_snippet` (multiline wajib dengan indentasi terjaga), dan `order` (bilangan bulat dengan nilai awal `0`).
  - **Tambah Proyek** (`ProjectFormPage` → `POST /api/v1/projects/`): `title` (wajib, maks 255), `description` (wajib), `category` (dropdown pilihan Django, default `Other`), `tech_stack` (opsional, maks 255), `project_url` (opsional, URL HTTP(S), maks 200), `project_image_url` (opsional, URL HTTP(S), maks 500), dan switch `is_featured` (default `false`).
- Dialog ringkasan bersama (`FormSummaryDialog`) yang muncul setelah `FormState.validate()` lolos dan `POST` ke backend berhasil, menampilkan seluruh field termasuk yang kosong (`-`), dapat digulir pada layar sempit, dan menyediakan dua aksi:
  - **Edit Isian**: menutup dialog sambil mempertahankan semua nilai (termasuk indentasi cuplikan kode) agar pengguna dapat memperbaiki isian.
  - **Selesai**: menutup dialog dan mereset form ke kondisi awal.

## Teknologi

- Flutter SDK dengan Dart `^3.13.7` pada [pubspec.yaml](pubspec.yaml).
- `material_ui: ^1.11.1` dan tema Material 3 untuk komponen antarmuka (paket Material resmi untuk Flutter `>= 3.47`).
- `http: ^1.6.0` untuk komunikasi HTTP REST dengan backend Django (`ApiClient`).
- `provider: ^6.1.5+1` untuk injeksi dependensi dan manajemen state (`ApiClient`, `AuthState`, `PortfolioRefreshNotifier`, `ProjectRefreshNotifier`).
- `json_annotation: ^4.12.0`, `json_serializable: ^6.15.2`, dan `build_runner: ^2.17.1` untuk generasi kode serialisasi JSON model.
- `flutter_svg: ^2.5.0` untuk merender ikon SVG jaringan pada komponen Tech Stack.
- `url_launcher: ^6.3.3` untuk membuka tautan URL proyek dari halaman detail.
- `flutter_lints: ^6.0.0` dan konfigurasi strict analyzer (`strict-casts`, `strict-inference`, `strict-raw-types`, serta aturan lint tambahan pada [analysis_options.yaml](analysis_options.yaml)) untuk analisis statis.
- `flutter_test` untuk pengujian unit dan widget.
- GitHub Actions CI/CD pada [.github/workflows/main.yaml](.github/workflows/main.yaml) (`VeryGoodOpenSource/very_good_workflows` + job `build_apk` yang menghasilkan artefak `app-release-apk`).

Versi Flutter/Dart yang terpasang di mesin pengembang dapat diperiksa dengan `flutter --version`.

## Struktur Proyek

```text
.github/
└── workflows/
    └── main.yaml                         # Pipeline CI (format, analyze, test) & build artefak app-release-apk
lib/
├── config.dart                           # Konfigurasi API_BASE_URL via --dart-define (default ke PWS)
├── main.dart                             # Titik masuk, MultiProvider, ThemeData, resolver rute web, & _WebPhoneViewport
├── data/
│   ├── dummy_portfolio.dart              # Fixture data lokal opsional untuk uji deterministik tanpa jaringan
│   └── portfolio_menu.dart               # Definisi menu kategori, koneksi live API per section, & builder halaman bagian
├── forms/
│   └── form_validators.dart              # Validator bersama (URL HTTP(S), teks wajib, panjang)
├── models/
│   ├── education.dart / .g.dart          # Model data Pendidikan & serialisasi JSON (id includeToJson: false)
│   ├── experience.dart / .g.dart         # Model data Pengalaman & serialisasi JSON (id includeToJson: false)
│   ├── item_homepage.dart                # Model item kategori menu beranda & drawer
│   ├── json_converters.dart              # Helper konversi ID, integer, dan tanggal untuk JSON
│   ├── project.dart / .g.dart            # Model data Proyek & serialisasi JSON (id includeToJson: false)
│   ├── skill.dart / .g.dart              # Model data Keahlian & serialisasi JSON (id includeToJson: false)
│   └── tech_stack.dart / .g.dart         # Model data Tech Stack & serialisasi JSON (id includeToJson: false)
├── screens/
│   ├── education_form.dart               # Halaman form Tambah Pendidikan (POST terautentikasi)
│   ├── experience_form.dart              # Halaman form Tambah Pengalaman (POST terautentikasi)
│   ├── login_screen.dart                 # Halaman login untuk menukarkan kredensial dengan token DRF
│   ├── menu.dart                         # Halaman utama (MyHomePage)
│   ├── portfolio_detail_page.dart        # Halaman detail lengkap item portofolio + aksi Hapus terautentikasi
│   ├── portfolio_section_page.dart       # Halaman bagian portofolio, tab, primaryBody/secondaryBody, & FAB auth
│   ├── project_form.dart                 # Halaman form Tambah Proyek (POST terautentikasi)
│   ├── skill_form.dart                   # Halaman form Tambah Keahlian (POST terautentikasi)
│   └── tech_stack_form.dart              # Halaman form Tambah Tech Stack (POST terautentikasi)
├── services/
│   ├── api_client.dart                   # HTTP client DRF (GET/POST/DELETE 5 entitas, timeout, close(), error parsing)
│   ├── auth_state.dart                   # State autentikasi token DRF in-memory (ChangeNotifier)
│   ├── portfolio_refresh_notifier.dart   # Notifier pembaruan daftar lintas section & drawer
│   └── project_refresh_notifier.dart     # Notifier kompatibilitas pembaruan daftar proyek
├── utils/
│   ├── api_error_formatter.dart          # Pemformat pesan error jaringan, timeout, & ApiException
│   ├── authenticated_action_helper.dart  # Helper bersama eksekusi aksi terautentikasi & penanganan 401 re-login
│   ├── date_formatter.dart               # Helper pemformatan tanggal ISO YYYY-MM-DD
│   ├── network_error_io.dart             # Deteksi SocketException pada platform IO
│   ├── network_error_stub.dart           # Stub deteksi error jaringan untuk platform non-IO (Web)
│   ├── portfolio_route_observer.dart     # Observer rute untuk navigasi kategori di LeftDrawer
│   └── url_launcher_helper.dart          # Helper pembuka tautan URL proyek
└── widgets/
    ├── auth_guard.dart                   # Route guard ensureLoggedIn menuju LoginScreen
    ├── code_snippet_box.dart             # Komponen kotak cuplikan kode bersama & CodeSnippetTheme
    ├── draft_confirm_dialog.dart         # Guard PopScope & dialog konfirmasi buang draf formulir
    ├── education_card.dart               # Kartu daftar Pendidikan
    ├── experience_card.dart              # Kartu daftar Pengalaman
    ├── form_summary_dialog.dart          # Dialog ringkasan bersama (Edit Isian & Selesai)
    ├── info_card.dart                    # Kartu informasi identitas
    ├── left_drawer.dart                  # Drawer navigasi bersama + submenu lipat Tambah Data
    ├── portfolio_async_list_view.dart    # Widget generik FutureBuilder asinkron + pull-to-refresh + Retry/Empty
    ├── portfolio_form_scaffold.dart      # Mixin dirty-state & scaffold standar halaman formulir
    ├── portfolio_network_image.dart      # Widget gambar jaringan dengan dukungan SVG & raster
    ├── portfolio_svg_loader_io.dart      # Pemuat SVG jaringan untuk platform IO
    ├── portfolio_svg_loader_stub.dart    # Pemuat SVG jaringan untuk platform non-IO (Web)
    ├── portfolio_svg_utils.dart          # Utilitas decode & validasi SVG Data URI bersama
    ├── profile_header.dart               # Header profil
    ├── project_card.dart                 # Kartu aksi menu (ItemCard)
    ├── project_item_card.dart            # Kartu daftar Proyek
    ├── project_list_view.dart            # Wrapper kompatibilitas daftar Proyek di atas PortfolioAsyncListView
    ├── skill_card.dart                   # Kartu daftar Keahlian
    └── tech_stack_card.dart              # Kartu daftar Tech Stack
test/
├── api_client_test.dart                  # Unit & lifecycle test ApiClient (GET/POST/DELETE 5 entitas, timeout, error)
├── api_error_ux_test.dart                # Pengujian UX error jaringan, timeout, & 401 di Login/Project
├── audit_regression_test.dart            # Uji regresi rute web, proteksi draf, SVG, & responsivitas
├── models_serialization_test.dart        # Unit test serialisasi JSON, id includeToJson: false, & value semantics
├── portfolio_async_list_view_test.dart   # Widget test PortfolioAsyncListView (loading, error/Retry, empty, refresh)
├── portfolio_sections_flow_test.dart     # Uji alur GET/POST/DELETE/401/Retry untuk 4 section non-Project & Tech Stack
├── project_flow_test.dart                # Uji alur refresh ProjectListView & submit ProjectFormPage
├── shared_helpers_test.dart              # Unit test helper formatIsoDate & portfolio_svg_utils
└── widget_test.dart                      # Widget test navigasi, validasi, dialog, auth guard, & layout
```

## Menjalankan Secara Lokal

### Prasyarat

- Flutter SDK yang menyertakan Dart `^3.13.7`. Periksa dengan `flutter --version`.
- Editor seperti Visual Studio Code dengan ekstensi Flutter atau Android Studio.
- Target eksekusi: Google Chrome, Android Emulator, atau perangkat Android (target iOS memerlukan macOS dan Xcode).
- Backend Django REST Framework:
  - **Deploy PWS (default):** [https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id](https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id)
  - **Repositori backend Django (opsional untuk pengembangan lokal):** [https://github.com/reshandytaftazani/myportofolio](https://github.com/reshandytaftazani/myportofolio)

### Langkah-langkah

Perintah berikut dijalankan dari direktori akar proyek. Secara default, `lib/config.dart` (serta artefak rilis `app-release-apk` dari CI) mengarah langsung ke backend PWS `https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id`.

1. Clone repositori dan masuk ke direktori proyek:

   ```bash
   git clone https://github.com/reshandytaftazani/myportofolio_mobile.git
   cd myportofolio_mobile
   ```

2. Ambil dependensi dan generate berkas serialisasi `*.g.dart` (wajib dijalankan karena `*.g.dart` diabaikan di `.gitignore`):

   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Jalankan aplikasi terhadap backend **PWS** (default):

   ```bash
   flutter run
   ```

4. *(Opsional)* Jika ingin menjalankan terhadap server Django lokal (`python manage.py runserver` pada repo `myportofolio`), override `API_BASE_URL` melalui `--dart-define`:

   - **Chrome / Web:**

     ```bash
     flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
     ```

   - **Android Emulator:**

     ```bash
     flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
     ```

   Daftar target yang terdeteksi dapat diperiksa dengan `flutter devices`.

### Pemecahan Masalah

| Gejala | Langkah penanganan |
| --- | --- |
| Perintah `flutter` tidak dikenali | Pastikan direktori `bin` Flutter SDK tercantum dalam `PATH`, lalu buka ulang terminal. |
| Error kompilasi `part '*.g.dart'` tidak ditemukan | Jalankan `dart run build_runner build --delete-conflicting-outputs` setelah `flutter pub get`. |
| `flutter pub get` menolak versi Dart | Periksa `flutter --version` dan gunakan Flutter SDK dengan versi Dart yang memenuhi batas pada `pubspec.yaml`. |
| Gagal terhubung ke API lokal | Pastikan server Django berjalan di port `8000` dan gunakan `http://localhost:8000` untuk Chrome atau `http://10.0.2.2:8000` untuk Android emulator via `--dart-define=API_BASE_URL=...`. |
| Perangkat tidak muncul | Jalankan `flutter doctor` dan `flutter devices`; nyalakan emulator atau aktifkan USB debugging pada perangkat Android. |

## Contoh Alur Demo

Alur berikut dapat digunakan untuk mendemokan integrasi penuh DRF dan autentikasi token dari beranda hingga operasi `GET`, `POST`, dan `DELETE`:

1. **Akses daftar publik (`GET`) & Detail Screen**: Tanpa login, buka kartu **Projects** (beserta tab **Tech Stack**), **Experiences**, **Education**, atau **Skills**. Daftar dimuat secara asinkron dari DRF (`PortfolioAsyncListView`); tarik ke bawah untuk *pull-to-refresh* dan ketuk salah satu kartu untuk membuka `PortfolioDetailPage` lengkap.
2. **Guard autentikasi (`ensureLoggedIn`)**: Saat belum login, ketuk tombol **Tambah** (FAB) atau buka submenu **Tambah Data** di `LeftDrawer`. Aplikasi otomatis mengarahkan ke `LoginScreen` untuk menukarkan kredensial dengan token DRF.
3. **Validasi & kirim data (`POST`)**: Setelah login, uji validasi form (mis. kosongkan field wajib, isi URL tidak valid, atau pilih `ended_at` sebelum `started_at`), lalu lengkapi isian valid dan tekan **Simpan**. Form terkunci selama pengiriman, mengirim `POST` dengan header `Authorization: Token <key>`, menampilkan `FormSummaryDialog`, dan menyegarkan daftar otomatis setelah kembali.
4. **Penanganan `401 Unauthorized`**: Bila token dicabut di sisi Django saat sesi masih aktif, pengiriman form atau aksi hapus otomatis membersihkan sesi (`AuthState.logout()`), menampilkan `SnackBar` sesi berakhir, dan meminta login ulang sambil mempertahankan isian form.
5. **Hapus data (`DELETE`) & Logout**: Buka `PortfolioDetailPage` pada entri uji coba, tekan ikon **Hapus** di `AppBar`, lalu konfirmasi pada dialog. Entri terhapus di backend dan daftar otomatis diperbarui. Terakhir, tekan **Logout** di `AppBar` atau `LeftDrawer`.

## Pengujian dan Analisis

Jalankan generasi kode, pemeriksaan format, analisis statis strict, dan seluruh pengujian dari direktori proyek:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### Hasil Pengujian Aktual

- **`dart format --output=none --set-exit-if-changed .`**: seluruh 66 berkas Dart terformat konsisten (`0 changed`).
- **`flutter analyze`**: `No issues found!` dengan konfigurasi strict (`strict-casts`, `strict-inference`, `strict-raw-types`, serta aturan lint pada `analysis_options.yaml`).
- **`flutter test`**: **106/106 tes lulus** (seluruh komunikasi HTTP diuji menggunakan `MockClient` / `HttpOverrides` tanpa panggilan jaringan sungguhan), terdiri dari:
  - **Unit & lifecycle test API di [test/api_client_test.dart](test/api_client_test.dart)**: menguji seluruh endpoint `GET`, `POST`, dan `DELETE` untuk 5 entitas (`Project`, `Experience`, `Education`, `Skill`, `TechStack`), timeout default & override, penutupan `http.Client` melalui `ApiClient.close()` dan `Provider.dispose`, serta ekstraksi error JSON DRF & fallback HTML 500.
  - **Pengujian UX error di [test/api_error_ux_test.dart](test/api_error_ux_test.dart)**: menguji `formatApiError`, pesan error ramah pada `LoginScreen`, `ProjectFormPage`, dan `ProjectListView` (termasuk pemulihan **Coba Lagi** dan redirect `401`).
  - **Widget test daftar asinkron di [test/portfolio_async_list_view_test.dart](test/portfolio_async_list_view_test.dart)**: menguji `PortfolioAsyncListView<T>` untuk state loading awal, error + **Coba Lagi**, empty state + *pull-to-refresh*, serta pertahanan cache saat refresh gagal.
  - **Uji alur section non-Project di [test/portfolio_sections_flow_test.dart](test/portfolio_sections_flow_test.dart)**: menguji alur `GET`, `POST` terautentikasi (tanpa field `id` & form lock), `401` re-login dengan mempertahankan isian form, `DELETE` terautentikasi dengan dialog konfirmasi, dan auto-refresh pada **Experiences**, **Education**, **Skills**, dan **Tech Stack**.
  - **Uji alur Proyek di [test/project_flow_test.dart](test/project_flow_test.dart)**: menguji *pull-to-refresh* tanpa menghilangkan daftar, batal kembali dari `ProjectFormPage` tanpa reload sia-sia, pembaruan otomatis daftar proyek setelah tambah via `LeftDrawer`, dan penguncian kontrol form saat submit.
  - **Unit test model di [test/models_serialization_test.dart](test/models_serialization_test.dart)**: menguji `fromJson`, `toJson` (termasuk verifikasi `id` tidak ikut diserialisasi berkat `includeToJson: false`), `copyWith`, `==`, dan `hashCode` untuk seluruh 5 model (`Education`, `Experience`, `Project`, `Skill`, `TechStack`).
  - **Unit test helper bersama di [test/shared_helpers_test.dart](test/shared_helpers_test.dart)**: menguji `formatIsoDate` serta utilitas decode & validasi SVG Data URI (`portfolio_svg_utils.dart`).
  - **Widget test di [test/widget_test.dart](test/widget_test.dart)**: menguji navigasi kartu beranda, halaman bagian, dan drawer menuju seluruh 5 form, validasi input, dialog ringkasan (`Edit Isian` & `Selesai`), `AuthState` & `ensureLoggedIn` pada semua aksi Tambah, serta keterjangkauan scroll pada layar sempit.
  - **Uji regresi di [test/audit_regression_test.dart](test/audit_regression_test.dart)**: menguji *decoupling* sumber data kosong, proteksi draf formulir & penggunaan ulang rute drawer, pemuatan ikon SVG (`SvgPicture`), resolusi rute kategori web (`/section/<name>`) & perilaku tombol Back saat drawer terbuka, serta responsivitas pada layar sempit.

### Pemeriksaan Manual (Backend PWS / Lokal)

| Skenario | Hasil yang diharapkan |
| --- | --- |
| Akses publik 5 entitas (`GET`) | **Projects**, **Tech Stack**, **Experiences**, **Education**, dan **Skills** tampil dari backend DRF tanpa login; mengetuk item membuka `PortfolioDetailPage` lengkap. |
| Guard autentikasi (`ensureLoggedIn`) | Menekan **Tambah** (FAB/drawer) atau **Hapus** saat belum login otomatis mengarahkan ke `LoginScreen`. |
| Submit form terautentikasi (`POST`) | Setelah login, isian valid terkirim ke DRF, daftar otomatis ter-refresh, dan data baru terverifikasi pada halaman web Django. |
| Simulasi `401 Unauthorized` | Menghapus token user di Django lalu mengirim form memicu `AuthState.logout()`, menampilkan `SnackBar` 401, dan membuka `LoginScreen` untuk login ulang. |
| Hapus item (`DELETE`) & Logout | Menekan **Hapus** di `PortfolioDetailPage` + konfirmasi menghapus item di backend & daftar; **Logout** mengembalikan status ke belum login secara bersih. |
| Layar ponsel (`390x844`) dan keyboard | Drawer, daftar, detail, form, dan dialog dapat digulir hingga aksi terakhir (`Simpan`, `Edit Isian`, `Selesai`). |

## Progres Mingguan

Ringkasan berikut mencatat progres implementasi pada riwayat Git proyek:

| Periode / kegiatan | Ringkasan pekerjaan | Bukti di riwayat Git | Status |
| --- | --- | --- | --- |
| 9–15 November 2026 — Tutorial 08 & Tugas 07 | Menyiapkan aplikasi dasar, header profil, kartu identitas, 6 menu beranda berwarna, SnackBar kontekstual, serta dokumentasi/refleksi/AI disclosure Tugas 7. | `9616c0e`, `8049b21`–`02d4ab5`, `83ffefa`–`3875f98` | Selesai |
| 17 November 2026 — Tutorial 09 | Menambahkan `LeftDrawer`, form awal Proyek, dialog ringkasan awal, navigasi dari kartu/drawer, serta refaktor struktur `models/`, `screens/`, `widgets/`. | `22d017c`, `0763f8f`, `33a638d`, `e7d61c0`, `0e9725f` | Selesai |
| 20–21 November 2026 — Form Pengalaman & Dialog Ringkasan (Tugas 08) | Membuat model & form `Experience` dengan validasi URL/tanggal, `FormSummaryDialog` dengan aksi **Edit Isian** & **Selesai**, integrasi kartu/drawer, dan widget test. | `c3b9ffc`, `798f680`, `e75aaad`, `217c8bc`, `290c9d8`, `0b623b6` | Selesai |
| 21 November 2026 — Form Pendidikan & Keahlian (Tugas 08) | Membuat model & form `Education` (validasi tahun 4 digit) dan `Skill` (cuplikan kode multiline), integrasi kartu/drawer, dan widget test. | `b1bebb4`, `49c97d8`, `947507f`, `a41dc2d`, `ecd9026` | Selesai |
| 21 November 2026 — Form Tech Stack & Validator Bersama (Tugas 08) | Membuat model & form `TechStack`, mengekstrak `form_validators.dart` bersama, integrasi kartu/drawer, dan uji ringkasan multiline. | `16a2790`, `af4b215`, `4a0ca52`, `056cd2a` | Selesai |
| 21 November 2026 — Penyelarasan Form Proyek dengan Django (Tugas 08) | Menyelaraskan `Project` dan `ProjectFormPage` dengan model Django (`project_url`, `project_image_url`, `is_featured`), memakai `FormSummaryDialog` bersama, dan memperbarui tes regresi. | `395afcd`, `2522436`, `680e632`, `8bb6ea8` | Selesai |
| 21 November 2026 — Verifikasi Akhir & Dokumentasi Tugas 08 | Verifikasi akhir (`flutter analyze` bersih, 14/14 `flutter test` lulus, pemeriksaan Chrome/perangkat) serta pembaruan panduan, struktur berkas, hasil uji, dan progres di `README.md`. | Branch `docs/tugas-8-final-verification-and-documentation`, `6199929` | Selesai |
| 21 November 2026 — Penyederhanaan Menu & Drawer | Menyederhanakan 10 kartu menu beranda menjadi 4 kategori (`Projects`, `Experiences`, `Education`, `Skills`), memindahkan `Logout` ke `AppBar`, menambahkan `PortfolioSectionPage`, dan menyamakan `LeftDrawer`. | `11224a0` | Selesai |
| 21 November 2026 — Sinkronisasi 5 Model & Serialisasi JSON | Menambahkan field `id`, status, dan *star* serta `fromJson`/`toJson` pada 5 model dan 8 unit test di `test/models_serialization_test.dart`. | `06a5979`–`bf42204`, `1d056b1` | Selesai |
| 21 November 2026 — Widget Card, Data Dummy, & Daftar Portofolio | Membuat 5 widget card, `DummyPortfolioData`, daftar `ListView.builder` pada `PortfolioSectionPage`, serta tab `Projects` & `Tech Stack`. | `e3333eb`–`6a4fec2`, `948f13a` | Selesai |
| 21 November 2026 — Halaman Detail Item & Navigasi Card | Membuat `PortfolioDetailPage` untuk ke-5 model dan menghubungkan navigasi `onTap` dari setiap card daftar ke halaman detail. | `6eefab0`, `067109d`, `5c62c9f` | Selesai |
| 21 November 2026 — Perbaikan Overflow Beranda, Refaktor Menu, & Pemformatan | Mengatasi overflow beranda, menyatukan status `Experience`, mengekstrak `portfolio_menu.dart`, merapikan form & navigasi, menambah uji regresi awal, dan menjalankan `dart format`. | `af65998`, `945ab0c` | Selesai |
| 22 November 2026 — Pratinjau Viewport Ponsel Web & Penyeragaman `InfoCard` | Menambahkan `_WebPhoneViewport` untuk mode debug Web dan menyamakan tinggi `InfoCard` pada halaman beranda. | `c8d7069` | Selesai |
| 22 November 2026 — Rute Kategori Web, Proteksi Draf Form, Dukungan SVG, & Regresi | Menambahkan resolver rute `/section/<name>`, `PortfolioRouteObserver`, `FormDraftPopScope` & dialog konfirmasi draf pada 5 form, pemuat SVG (`flutter_svg`), tautan URL (`url_launcher`), izin jaringan Android/macOS, perbaikan responsivitas, serta memperluas `test/audit_regression_test.dart` hingga 49/49 tes lulus. | `d831a7d` | Selesai |
| 25 November 2026 — Integrasi DRF & Autentikasi Token (Tutorial 10) | Menambahkan `ApiClient`, `AuthState`, `LoginScreen`, `ensureLoggedIn`, `ProjectListView`, proteksi aksi tambah proyek, workflow CI `.github/workflows/main.yaml`, serta pembaruan tes unit & widget. | `d80f242`–`0188de7` | Selesai |
| 25 November 2026 — Hardening Networking & Penanganan Error API | Menambahkan timeout HTTP 15 detik, `ApiClient.close()` melalui `Provider.dispose` dan fallback `ProjectListView`, parsing error JSON DRF & fallback HTML 500 aman, pemformat pesan ramah `formatApiError`, serta unit/widget test terkait. | `0f9dc6c`, `0fa49a3`, `af2b918`, `7e0b59b` | Selesai |
| 25 November 2026 — Perbaikan UX Refresh, Sinkronisasi Daftar Proyek, & Penguncian Form | Mempertahankan daftar saat *pull-to-refresh* di `ProjectListView`, mencegah GET reload sia-sia saat batal dari `ProjectFormPage`, menyinkronkan refresh lintas FAB/`LeftDrawer` lewat `ProjectRefreshNotifier`, mengunci input selama submit, serta menambah `test/project_flow_test.dart`. | `8ab4a17`, `08b4a17`, `3f75723` | Selesai |
| 25 November 2026 — Konfigurasi Keamanan Jaringan Android & Dokumentasi Sesi Auth | Membatasi *cleartext HTTP* Android hanya untuk host lokal debug (`network_security_config.xml`) dan mendokumentasikan alasan desain penyimpanan token *in-memory* pada `AuthState`. | `fbf145e`, `27d4daa` | Selesai |
| 25 November 2026 — Serialisasi `@JsonSerializable`, Sentralisasi Theme, & Pemulihan `material_ui` | Menyeragamkan ke-5 model dengan `@JsonSerializable` + `copyWith`/`==`/`hashCode`, memusatkan `AppBarTheme` & `FilledButtonThemeData` di `ThemeData`, mengekstrak `CodeSnippetBox`, serta memakai `package:material_ui/material_ui.dart` sesuai depresiasi `flutter/material.dart` pada Flutter `>= 3.47` di CI. | `22b8b21`, `441cefa`, `0bf5f84`, `b717cf5` | Selesai |
| 25 November 2026 — Deduplikasi Helper/Form, Penyeragaman Bahasa UI, & Strict Lints | Mengekstrak `formatIsoDate`, `portfolio_svg_utils.dart`, dan `FormDraftStateMixin`/`PortfolioFormScaffold`; menyeragamkan label UI Bahasa Indonesia; mengaktifkan strict analyzer (`strict-casts`, `strict-inference`, `strict-raw-types`) dan lint tambahan (`84/84` tes lulus). | `0d8c3f4`, `dcf1ba8`, `98dc777`, `04926f1` | Selesai |
| 26 November 2026 — Autentikasi Token Backend, Penyelarasan Model, & Perluasan `ApiClient` (Tugas 09) | Mengaktifkan `TokenAuthentication` untuk 4 section di repo backend `myportofolio` (deploy PWS), mengecualikan `id` dari `toJson()` pada seluruh 5 model, menambah metode `GET`/`POST`/`DELETE` di `ApiClient`, serta unit test `MockClient`. | Branch `feat/tugas-9-api-and-models`: `3ff2f66`, `60c6c62`, `1881025`, `cf7cc7b` | Selesai |
| 26 November 2026 — Daftar Live API 4 Section & Widget `PortfolioAsyncListView` (Tugas 09) | Mengekstrak `PortfolioAsyncListView<T>` & `PortfolioRefreshNotifier` dan menghubungkan daftar *live* API untuk **Experiences**, **Education**, **Skills**, dan tab **Tech Stack** dengan `requiresAuth: true` pada seluruh aksi Tambah. | Branch `feat/tugas-9-async-lists`: `0b7f4ec`, `d6d0492` | Selesai |
| 26 November 2026 — Integrasi POST 5 Formulir & Aksi Hapus Terautentikasi (Tugas 09) | Mengekstrak `authenticated_action_helper.dart` (penanganan `401` bersama), menghubungkan seluruh 5 form ke `POST` terautentikasi, dan menambahkan aksi **Hapus** terautentikasi dengan dialog konfirmasi di `PortfolioDetailPage`. | Branch `feat/tugas-9-auth-forms-and-crud`: `e1db243`, `2af93ce`, `0b8448f`, `f563143` | Selesai |
| 26 November 2026 — Pengujian Integrasi, Konfigurasi Backend PWS, & Submenu Drawer (Tugas 09) | Menambah uji alur `GET`/`POST`/`DELETE`/`401`/Retry (`106/106` tes lulus), mengarahkan default `API_BASE_URL` & build APK CI ke PWS, menambahkan submenu lipat **Tambah Data** di `LeftDrawer`, dan melakukan pengujian end-to-end. | Branch `test/tugas-9-integration-tests`: `4f89ee8`, `6cdd961`, `377faf8` | Selesai |
| 26 November 2026 — Badge CI & Sinkronisasi Dokumentasi Integrasi (Tugas 09) | Menambahkan badge CI GitHub Actions di `README.md`, menyinkronkan dokumentasi fitur, struktur proyek, panduan setup PWS/lokal, hasil uji (`106/106`), progres mingguan, dan keterbatasan. | Branch `docs/tugas-9-documentation` | Selesai |

## Keterbatasan Saat Ini

- Token autentikasi DRF pada `AuthState` sengaja disimpan hanya di memori (*in-memory*) sesuai spesifikasi Tutorial 10 sehingga sesi login berakhir saat aplikasi ditutup atau dimulai ulang, serta untuk menghindari penyimpanan token mentah pada storage lokal non-terenkripsi.
- Konten profil masih didefinisikan secara statis di `lib/screens/menu.dart`, sedangkan konfigurasi 4 kategori menu beranda berada di `lib/data/portfolio_menu.dart` dan belum diambil dari backend.
- Aplikasi mobile saat ini mendukung operasi `GET`, `POST`, dan `DELETE` terautentikasi untuk kelima entitas portofolio; operasi ubah (`PATCH`/`PUT`) dan tombol *star* dari sisi mobile belum diimplementasikan.

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

