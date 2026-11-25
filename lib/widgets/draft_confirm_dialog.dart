import 'package:flutter/material.dart';

/// Menampilkan dialog konfirmasi sebelum membuang perubahan draf pada formulir.
///
/// Mengembalikan `true` jika pengguna memilih untuk membuang draf dan keluar,
/// atau `false` jika pengguna memilih tetap berada di halaman formulir.
Future<bool> showDiscardDraftDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Buang Perubahan Draf?'),
      content: const Text(
        'Anda memiliki isian formulir yang belum disimpan. '
        'Apakah Anda yakin ingin membuang draf ini dan meninggalkan halaman?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Buang'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Pembungkus [PopScope] untuk mencegah pengguna tidak sengaja keluar dari
/// halaman formulir yang memiliki perubahan draf belum disimpan.
class FormDraftPopScope extends StatelessWidget {
  final bool isDirty;
  final Widget child;
  final Object? popResult;

  const FormDraftPopScope({
    super.key,
    required this.isDirty,
    required this.child,
    this.popResult,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !isDirty && popResult == null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final route = ModalRoute.of(context);
        if (route?.willHandlePopInternally ?? false) {
          Navigator.of(context).pop();
          return;
        }
        if (!isDirty) {
          Navigator.of(context).pop(popResult);
          return;
        }
        final shouldDiscard = await showDiscardDraftDialog(context);
        if (shouldDiscard && context.mounted) {
          Navigator.of(context).pop(popResult);
        }
      },
      child: child,
    );
  }
}
