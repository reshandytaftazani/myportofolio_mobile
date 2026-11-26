import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/utils/authenticated_action_helper.dart';
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

  bool _isSubmitting = false;
  bool _hasCreatedSkill = false;

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

    final result = await runAuthenticatedAction<Skill>(
      context: context,
      action: (apiClient, token) => apiClient.createSkill(skill, token: token),
      errorActionLabel: 'Gagal menyimpan keahlian',
      reLoginSuccessMessage:
          'Login berhasil. Tekan Simpan untuk mengirim ulang keahlian.',
      onSubmittingChanged: (isSubmitting) {
        setState(() {
          _isSubmitting = isSubmitting;
        });
      },
    );

    if (!result.succeeded || !mounted) return;
    final created = result.data!;

    setState(() {
      _hasCreatedSkill = true;
    });

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Keahlian Berhasil Disimpan',
      entries: [
        FormSummaryEntry(label: 'Nama Keahlian', value: created.title),
        FormSummaryEntry(label: 'Level', value: created.level),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: created.description,
          isMultiline: true,
        ),
        FormSummaryEntry(
          label: 'Cuplikan Kode',
          value: created.codeSnippet,
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
      popResult: _hasCreatedSkill ? true : null,
      children: [
        TextFormField(
          controller: _titleController,
          enabled: !_isSubmitting,
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
          enabled: !_isSubmitting,
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
          enabled: !_isSubmitting,
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
          enabled: !_isSubmitting,
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Text('Simpan'),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
