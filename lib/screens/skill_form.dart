import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan entri Keahlian baru.
class SkillFormPage extends StatefulWidget {
  const SkillFormPage({super.key});

  @override
  State<SkillFormPage> createState() => _SkillFormPageState();
}

class _SkillFormPageState extends State<SkillFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _levelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeSnippetController = TextEditingController();

  bool _wasDirty = false;

  bool get _isDirty =>
      _titleController.text.isNotEmpty ||
      _levelController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _codeSnippetController.text.isNotEmpty;

  void _syncDirtyState() {
    final dirty = _isDirty;
    if (dirty != _wasDirty) {
      setState(() {
        _wasDirty = dirty;
      });
    }
  }

  Future<bool> _confirmDiscardDraft() async {
    if (!_isDirty) return true;
    return showDiscardDraftDialog(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _levelController.dispose();
    _descriptionController.dispose();
    _codeSnippetController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _levelController.clear();
    _descriptionController.clear();
    _codeSnippetController.clear();
    _syncDirtyState();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final rawCode = _codeSnippetController.text;
    final skill = Skill(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      level: _levelController.text.trim(),
      codeSnippet: rawCode.trim().isEmpty ? null : rawCode,
    );

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Ringkasan Keahlian',
      entries: [
        FormSummaryEntry(label: 'Nama Keahlian', value: skill.title),
        FormSummaryEntry(label: 'Level', value: skill.level),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: skill.description,
          isMultiline: true,
        ),
        FormSummaryEntry(
          label: 'Cuplikan Kode',
          value: skill.codeSnippet,
          isCode: true,
        ),
      ],
    );

    if (shouldReset == true && mounted) {
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDraftPopScope(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tambah Keahlian')),
        drawer: LeftDrawer(onWillNavigate: _confirmDiscardDraft),
        body: Form(
          key: _formKey,
          onChanged: _syncDirtyState,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Keahlian',
                    hintText: 'Contoh: Flutter & Dart',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Nama keahlian',
                    maxLength: 255,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _levelController,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    hintText: 'Contoh: Intermediate',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Level',
                    maxLength: 50,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Keahlian',
                    hintText: 'Jelaskan pengalaman dan penerapan keahlian ini',
                  ),
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Deskripsi keahlian',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _codeSnippetController,
                  maxLines: 6,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.0,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Cuplikan Kode (Opsional)',
                    hintText: 'void main() {\n  print("Hello");\n}',
                  ),
                ),
                const SizedBox(height: 24.0),
                FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Simpan'),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
