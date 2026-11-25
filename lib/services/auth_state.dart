import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan state autentikasi token DRF hanya di memori (*in-memory*) untuk
/// sesi aplikasi yang sedang berjalan.
///
/// **Alasan desain (Tutorial 10):**
/// - Spesifikasi Tutorial 10 menetapkan token disimpan di memori selama sesi
///   berlangsung (sesi berakhir saat aplikasi ditutup/di-restart).
/// - Menghindari penyimpanan token mentah di storage lokal non-terenkripsi
///   (mis. `SharedPreferences`) serta menjaga inisialisasi [AuthState] tetap
///   sinkron dan deterministik untuk widget/regression test.
/// - Jika persistensi lintas restart dibutuhkan di masa depan (mis. Tugas 9),
///   abstraksikan penyimpanan via interface `TokenStorage` dengan implementasi
///   terenkripsi (`flutter_secure_storage`) dan fallback *in-memory* untuk tes.
class AuthState extends ChangeNotifier {
  final ApiClient _apiClient;
  String? _token;

  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  /// Token autentikasi aktif, atau `null` jika belum login.
  String? get token => _token;

  /// Bernilai `true` apabila pengguna sedang login dan memiliki token.
  bool get isLoggedIn => _token != null;

  /// Melakukan login dengan menukarkan kredensial menjadi token DRF.
  Future<void> login(String username, String password) async {
    final obtainedToken = await _apiClient.obtainToken(username, password);
    _token = obtainedToken;
    notifyListeners();
  }

  /// Mencabut token di backend (jika ada) dan membersihkan state token lokal.
  Future<void> logout() async {
    final current = _token;
    if (current == null) {
      return;
    }

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Tetap bersihkan token lokal meskipun server menolak pencabutan token.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
