import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/utils/authenticated_action_helper.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_form_scaffold.dart';

/// Halaman formulir untuk menambahkan entri Proyek baru.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage>
    with FormDraftStateMixin<ProjectFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _projectImageUrlController = TextEditingController();

  String _category = Project.defaultCategory;
  bool _isFeatured = false;
  bool _isSubmitting = false;
  bool _hasCreatedProject = false;

  @override
  bool get isFormDirty =>
      _titleController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _techStackController.text.isNotEmpty ||
      _projectUrlController.text.isNotEmpty ||
      _projectImageUrlController.text.isNotEmpty ||
      _category != Project.defaultCategory ||
      _isFeatured;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _projectImageUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _techStackController.clear();
    _projectUrlController.clear();
    _projectImageUrlController.clear();
    setFormState(() {
      _category = Project.defaultCategory;
      _isFeatured = false;
    });
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      techStack: _techStackController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      projectImageUrl: _projectImageUrlController.text.trim(),
      isFeatured: _isFeatured,
    );

    final result = await runAuthenticatedAction<Project>(
      context: context,
      action: (apiClient, token) =>
          apiClient.createProject(project, token: token),
      errorActionLabel: 'Gagal menyimpan proyek',
      reLoginSuccessMessage:
          'Login berhasil. Tekan Simpan untuk mengirim ulang proyek.',
      onSubmittingChanged: (isSubmitting) {
        setState(() {
          _isSubmitting = isSubmitting;
        });
      },
    );

    if (!result.succeeded || !mounted) return;
    final created = result.data!;

    setState(() {
      _hasCreatedProject = true;
    });
    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Proyek Berhasil Disimpan',
      entries: [
        FormSummaryEntry(label: 'Nama Proyek', value: created.title),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: created.description,
          isMultiline: true,
        ),
        FormSummaryEntry(label: 'Kategori', value: created.category),
        FormSummaryEntry(label: 'Tech Stack', value: created.techStack),
        FormSummaryEntry(label: 'Tautan Proyek', value: created.projectUrl),
        FormSummaryEntry(
          label: 'URL Gambar Proyek',
          value: created.projectImageUrl,
        ),
        FormSummaryEntry(
          label: 'Proyek Unggulan',
          value: created.isFeatured ? 'Ya' : 'Tidak',
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
      title: 'Tambah Proyek',
      popResult: _hasCreatedProject ? true : null,
      children: [
        TextFormField(
          controller: _titleController,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Nama Proyek',
            hintText: 'Nama Proyek',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => validateRequiredText(
            value,
            fieldLabel: 'Nama proyek',
            maxLength: 255,
            emptySuffix: '!',
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _descriptionController,
          enabled: !_isSubmitting,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            labelText: 'Deskripsi Proyek',
            hintText: 'Deskripsi Proyek',
          ),
          validator: (value) => validateRequiredText(
            value,
            fieldLabel: 'Deskripsi proyek',
            emptySuffix: '!',
          ),
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Kategori Proyek'),
          items: Project.categoryChoices
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (newValue) {
                  if (newValue == null) return;
                  setFormState(() {
                    _category = newValue;
                  });
                },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _techStackController,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Tech Stack (Opsional)',
            hintText: 'Contoh: Flutter, Django, PostgreSQL',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value != null && value.trim().length > 255) {
              return 'Tech stack maksimal 255 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _projectUrlController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Tautan Proyek (Opsional)',
            hintText: 'https://example.com/project',
          ),
          validator: (value) =>
              validateHttpUrl(value, fieldLabel: 'URL proyek', maxLength: 200),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _projectImageUrlController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'URL Gambar Proyek (Opsional)',
            hintText: 'https://example.com/cover.png',
          ),
          validator: (value) => validateHttpUrl(
            value,
            fieldLabel: 'URL gambar proyek',
            maxLength: 500,
          ),
        ),
        const SizedBox(height: 8.0),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Proyek Unggulan'),
          subtitle: const Text('Tandai sebagai proyek unggulan di portofolio'),
          value: _isFeatured,
          onChanged: _isSubmitting
              ? null
              : (value) {
                  setFormState(() {
                    _isFeatured = value;
                  });
                },
        ),
        const SizedBox(height: 16.0),
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
