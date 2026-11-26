import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/api_error_formatter.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Hasil eksekusi aksi API terautentikasi dari [runAuthenticatedAction].
class AuthenticatedActionResult<T> {
  /// Bernilai `true` apabila aksi selesai tanpa error dan tidak dibatalkan.
  final bool succeeded;

  /// Nilai kembalian aksi ketika [succeeded] bernilai `true`.
  final T? data;

  const AuthenticatedActionResult.success([this.data]) : succeeded = true;

  const AuthenticatedActionResult.failure() : succeeded = false, data = null;
}

/// Menjalankan aksi API terautentikasi secara seragam di seluruh formulir
/// dan halaman detail.
///
/// Alur yang ditangani:
/// 1. Memastikan pengguna sudah login melalui [ensureLoggedIn].
/// 2. Membaca token aktif dari [AuthState] dan [ApiClient] dari [Provider].
/// 3. Memanggil [onSubmittingChanged] dengan `true` saat permintaan berjalan
///    dan `false` di blok `finally` selama widget masih terpasang.
/// 4. Menangani [ApiException] `401` dengan membersihkan sesi (`logout()`),
///    menampilkan `SnackBar`, dan mengarahkan ke login ulang.
/// 5. Menangani [ApiException] lain maupun error jaringan/timeout dengan
///    `SnackBar` ramah pengguna melalui [formatApiError].
Future<AuthenticatedActionResult<T>> runAuthenticatedAction<T>({
  required BuildContext context,
  required Future<T> Function(ApiClient apiClient, String token) action,
  required String errorActionLabel,
  String reLoginSuccessMessage =
      'Login berhasil. Silakan ulangi aksi sebelumnya.',
  ValueChanged<bool>? onSubmittingChanged,
}) async {
  final loggedIn = await ensureLoggedIn(context);
  if (!loggedIn || !context.mounted) {
    return AuthenticatedActionResult<T>.failure();
  }

  final authState = context.read<AuthState>();
  final token = authState.token;
  if (token == null) {
    return AuthenticatedActionResult<T>.failure();
  }

  final apiClient = context.read<ApiClient>();
  onSubmittingChanged?.call(true);

  try {
    final data = await action(apiClient, token);
    return AuthenticatedActionResult<T>.success(data);
  } on ApiException catch (e) {
    if (!context.mounted) {
      return AuthenticatedActionResult<T>.failure();
    }
    if (e.statusCode == 401) {
      await authState.logout();
      if (!context.mounted) {
        return AuthenticatedActionResult<T>.failure();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login berakhir (401). Silakan login kembali.'),
        ),
      );
      final reLoggedIn = await ensureLoggedIn(context);
      if (reLoggedIn && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(reLoginSuccessMessage)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatApiError(e, actionLabel: errorActionLabel)),
        ),
      );
    }
    return AuthenticatedActionResult<T>.failure();
  } catch (e) {
    if (!context.mounted) {
      return AuthenticatedActionResult<T>.failure();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(formatApiError(e, actionLabel: errorActionLabel))),
    );
    return AuthenticatedActionResult<T>.failure();
  } finally {
    if (context.mounted) {
      onSubmittingChanged?.call(false);
    }
  }
}
