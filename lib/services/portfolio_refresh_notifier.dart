import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';

/// Target daftar portofolio yang dapat disegarkan secara independen.
enum PortfolioRefreshTarget {
  projects,
  techStacks,
  experiences,
  education,
  skills,
}

/// Memetakan [PortfolioSection] ke [PortfolioRefreshTarget] utamanya.
extension PortfolioSectionRefreshTarget on PortfolioSection {
  /// Target refresh utama untuk bagian portofolio ini.
  PortfolioRefreshTarget get refreshTarget {
    switch (this) {
      case PortfolioSection.projects:
        return PortfolioRefreshTarget.projects;
      case PortfolioSection.experiences:
        return PortfolioRefreshTarget.experiences;
      case PortfolioSection.education:
        return PortfolioRefreshTarget.education;
      case PortfolioSection.skills:
        return PortfolioRefreshTarget.skills;
    }
  }
}

/// Notifier lintas layar untuk memicu pemuatan ulang daftar portofolio
/// per target ([PortfolioRefreshTarget]) secara selektif.
///
/// Melacak nomor versi terpisah untuk setiap target sehingga pembaruan pada
/// satu bagian (misalnya `experiences`) tidak menyebabkan bagian lain ikut
/// memuat ulang data secara tidak perlu.
class PortfolioRefreshNotifier extends ChangeNotifier {
  final Map<PortfolioRefreshTarget, int> _versions = {
    for (final target in PortfolioRefreshTarget.values) target: 0,
  };

  /// Versi sinyal refresh saat ini untuk [target].
  int versionFor(PortfolioRefreshTarget target) => _versions[target] ?? 0;

  /// Mengirim sinyal bahwa daftar pada [target] perlu dimuat ulang.
  void requestRefresh(PortfolioRefreshTarget target) {
    _versions[target] = versionFor(target) + 1;
    notifyListeners();
  }

  /// Mengirim sinyal refresh untuk target utama dari [section].
  void requestSectionRefresh(PortfolioSection section) {
    requestRefresh(section.refreshTarget);
  }

  /// Mengirim sinyal refresh untuk seluruh target daftar portofolio.
  void requestRefreshAll() {
    for (final target in PortfolioRefreshTarget.values) {
      _versions[target] = versionFor(target) + 1;
    }
    notifyListeners();
  }
}
