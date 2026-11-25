import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_form_scaffold.dart';

/// Halaman formulir untuk menambahkan entri Keahlian baru.
class SkillFormPage extends StatefulWidget {
  const SkillFormPage({super.key});

  @override
  State<SkillFormPage> createState() => _SkillFormPageState();
}

class _SkillFormPageState extends State<SkillFormPage>
    with FormDraftStateMixin<SkillFormPage> {
  final _titleController = TextEditingController();
  final _levelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeSnippetController = TextEditingController();

  @override
  bool get isFormDirty =>
      _titleController.text.isNotEmpty ||
      _levelController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _codeSnippetController.text.isNotEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    _levelController.dispose();
    _descriptionController.dispose();
    _codeSnippetController.dispose();
    super.dispose();
  }

  void _resetForm() {
    formKey.currentState?.reset();
    _titleController.clear();
    _levelController.clear();
    _descriptionController.clear();
    _codeSnippetController.clear();
    syncDirtyState();
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

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
    return buildFormScaffold(
      title: 'Tambah Keahlian',
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
          validator: (value) =>
              validateRequiredText(value, fieldLabel: 'Level', maxLength: 50),
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
          validator: (value) =>
              validateRequiredText(value, fieldLabel: 'Deskripsi keahlian'),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _codeSnippetController,
          maxLines: 6,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13.0),
          decoration: const InputDecoration(
            labelText: 'Cuplikan Kode (Opsional)',
            hintText: 'void main() {\n  print("Hello");\n}',
          ),
        ),
        const SizedBox(height: 24.0),
        FilledButton(onPressed: _submitForm, child: const Text('Simpan')),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
