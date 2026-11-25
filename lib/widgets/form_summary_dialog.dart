import 'package:flutter/material.dart';

/// Satu baris data yang ditampilkan pada [FormSummaryDialog].
class FormSummaryEntry {
  final String label;
  final String? value;
  final bool isMultiline;
  final bool isCode;

  const FormSummaryEntry({
    required this.label,
    this.value,
    this.isMultiline = false,
    this.isCode = false,
  });
}

/// Menampilkan dialog ringkasan isian form dengan aksi **Edit Isian** dan **Selesai**.
///
/// Mengembalikan `true` jika pengguna menekan **Selesai** (reset form),
/// atau `false`/`null` jika pengguna menekan **Edit Isian** / menutup dialog.
Future<bool?> showFormSummaryDialog({
  required BuildContext context,
  required String title,
  required List<FormSummaryEntry> entries,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) =>
        FormSummaryDialog(title: title, entries: entries),
  );
}

/// Dialog ringkasan yang dapat digulir untuk memverifikasi isian sebelum selesai.
class FormSummaryDialog extends StatelessWidget {
  final String title;
  final List<FormSummaryEntry> entries;

  const FormSummaryDialog({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map(_buildEntry).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Edit Isian'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Selesai'),
        ),
      ],
    );
  }

  Widget _buildEntry(FormSummaryEntry entry) {
    final rawValue = entry.value;
    final isEmpty = rawValue == null || rawValue.trim().isEmpty;
    final displayValue = isEmpty
        ? '-'
        : (entry.isCode ? rawValue : rawValue.trim());

    if (entry.isMultiline || entry.isCode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.label}:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                displayValue,
                style: entry.isCode
                    ? const TextStyle(fontFamily: 'monospace', fontSize: 13.0)
                    : null,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${entry.label}: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: displayValue),
          ],
        ),
      ),
    );
  }
}
