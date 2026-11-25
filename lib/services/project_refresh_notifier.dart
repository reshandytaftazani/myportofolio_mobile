import 'package:flutter/foundation.dart';

/// Notifier untuk memicu pemuatan ulang daftar proyek lintas layar
/// (misalnya setelah menambah proyek via FAB atau LeftDrawer).
class ProjectRefreshNotifier extends ChangeNotifier {
  int _version = 0;

  /// Versi sinyal refresh saat ini.
  int get version => _version;

  /// Mengirim sinyal bahwa daftar proyek perlu dimuat ulang.
  void requestRefresh() {
    _version++;
    notifyListeners();
  }
}
