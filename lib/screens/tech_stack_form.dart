import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_form_scaffold.dart';

/// Halaman formulir untuk menambahkan entri Tech Stack baru.
class TechStackFormPage extends StatefulWidget {
  const TechStackFormPage({super.key});

  @override
  State<TechStackFormPage> createState() => _TechStackFormPageState();
}

class _TechStackFormPageState extends State<TechStackFormPage>
    with FormDraftStateMixin<TechStackFormPage> {
  final _nameController = TextEditingController();
  final _iconUrlController = TextEditingController();
  final _filenameController = TextEditingController();
  final _codeSnippetController = TextEditingController();
  final _orderController = TextEditingController(text: '0');

  @override
  bool get isFormDirty =>
      _nameController.text.isNotEmpty ||
      _iconUrlController.text.isNotEmpty ||
      _filenameController.text.isNotEmpty ||
      _codeSnippetController.text.isNotEmpty ||
      _orderController.text.trim() != '0';

  @override
  void dispose() {
    _nameController.dispose();
    _iconUrlController.dispose();
    _filenameController.dispose();
    _codeSnippetController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _resetForm() {
    formKey.currentState?.reset();
    _nameController.clear();
    _iconUrlController.clear();
    _filenameController.clear();
    _codeSnippetController.clear();
    _orderController.text = '0';
    syncDirtyState();
  }

  String? _validateOrder(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Urutan tampil tidak boleh kosong.';
    }
    if (int.tryParse(trimmed) == null) {
      return 'Urutan tampil harus berupa bilangan bulat.';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final techStack = TechStack(
      name: _nameController.text.trim(),
      iconUrl: _iconUrlController.text.trim(),
      filename: _filenameController.text.trim(),
      codeSnippet: _codeSnippetController.text,
      order: int.parse(_orderController.text.trim()),
    );

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Ringkasan Tech Stack',
      entries: [
        FormSummaryEntry(label: 'Nama Tech Stack', value: techStack.name),
        FormSummaryEntry(label: 'URL Ikon', value: techStack.iconUrl),
        FormSummaryEntry(label: 'Nama File', value: techStack.filename),
        FormSummaryEntry(
          label: 'Cuplikan Kode',
          value: techStack.codeSnippet,
          isCode: true,
        ),
        FormSummaryEntry(
          label: 'Urutan Tampil',
          value: techStack.order.toString(),
        ),
      ],
    );

    if (shouldReset == true && mounted) {
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildFormScaffold(
      title: 'Tambah Tech Stack',
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Tech Stack',
            hintText: 'Contoh: Dart',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => validateRequiredText(
            value,
            fieldLabel: 'Nama tech stack',
            maxLength: 50,
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _iconUrlController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'URL Ikon',
            hintText: 'https://cdn.example.com/dart.svg',
          ),
          validator: (value) => validateHttpUrl(
            value,
            fieldLabel: 'URL ikon',
            required: true,
            maxLength: 200,
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _filenameController,
          decoration: const InputDecoration(
            labelText: 'Nama File',
            hintText: 'Contoh: main.dart',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => validateRequiredText(
            value,
            fieldLabel: 'Nama file',
            maxLength: 50,
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _codeSnippetController,
          maxLines: 6,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13.0),
          decoration: const InputDecoration(
            labelText: 'Cuplikan Kode',
            hintText: 'void main() {\n  print("Dart");\n}',
          ),
          validator: (value) =>
              validateRequiredText(value, fieldLabel: 'Cuplikan kode'),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _orderController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Urutan Tampil',
            hintText: '0',
          ),
          validator: _validateOrder,
        ),
        const SizedBox(height: 24.0),
        FilledButton(onPressed: _submitForm, child: const Text('Simpan')),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
