import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan entri Proyek baru.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _projectImageUrlController = TextEditingController();

  String _category = Project.defaultCategory;
  bool _isFeatured = false;
  bool _wasDirty = false;
  bool _isSubmitting = false;

  bool get _isDirty =>
      _titleController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _techStackController.text.isNotEmpty ||
      _projectUrlController.text.isNotEmpty ||
      _projectImageUrlController.text.isNotEmpty ||
      _category != Project.defaultCategory ||
      _isFeatured;

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
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _projectImageUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _techStackController.clear();
    _projectUrlController.clear();
    _projectImageUrlController.clear();
    setState(() {
      _category = Project.defaultCategory;
      _isFeatured = false;
      _wasDirty = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      techStack: _techStackController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      projectImageUrl: _projectImageUrlController.text.trim(),
      isFeatured: _isFeatured,
    );

    setState(() {
      _isSubmitting = true;
    });

    final Project created;
    try {
      created = await context.read<ApiClient>().createProject(
        project,
        token: token,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi login berakhir (401). Silakan login kembali.'),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan proyek (${e.statusCode}): ${e.message}',
            ),
          ),
        );
      }
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) return;
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
    final colorScheme = Theme.of(context).colorScheme;

    return FormDraftPopScope(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Project Form',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
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
                  decoration: const InputDecoration(
                    labelText: 'Kategori Proyek',
                  ),
                  items: Project.categoryChoices
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue == null) return;
                    setState(() {
                      _category = newValue;
                      _wasDirty = _isDirty;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _techStackController,
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
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tautan Proyek (Opsional)',
                    hintText: 'https://example.com/project',
                  ),
                  validator: (value) => validateHttpUrl(
                    value,
                    fieldLabel: 'URL proyek',
                    maxLength: 200,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _projectImageUrlController,
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
                  subtitle: const Text(
                    'Tandai sebagai proyek unggulan di portofolio',
                  ),
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() {
                      _isFeatured = value;
                      _wasDirty = _isDirty;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
