import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hook opsional untuk mengganti peluncur URL pada pengujian widget.
typedef UrlLauncherHandler = Future<bool> Function(Uri uri);

/// Override yang dapat diatur saat pengujian untuk memverifikasi pembukaan URL.
@visibleForTesting
UrlLauncherHandler? debugUrlLauncherOverride;

/// Membuka [rawUrl] menggunakan browser/aplikasi eksternal.
///
/// Menampilkan [SnackBar] peringatan jika tautan tidak valid atau gagal dibuka.
Future<bool> launchExternalUrl(BuildContext context, String rawUrl) async {
  final trimmed = rawUrl.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Tautan proyek tidak valid.')),
        );
    }
    return false;
  }

  try {
    final handler = debugUrlLauncherOverride;
    final launched = handler != null
        ? await handler(uri)
        : await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka tautan $trimmed')),
        );
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka tautan $trimmed')),
        );
    }
    return false;
  }
}
