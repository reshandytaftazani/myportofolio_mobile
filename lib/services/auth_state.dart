import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan state autentikasi token DRF di memori aplikasi.
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
