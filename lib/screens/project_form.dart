import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

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
  final _projectUrlController = TextEditingController();
  final _projectImageUrlController = TextEditingController();

  String _category = Project.defaultCategory;
  bool _isFeatured = false;
  bool _wasDirty = false;

  bool get _isDirty =>
      _titleController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
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
    _projectUrlController.dispose();
    _projectImageUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
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

    final projectUrl = _projectUrlController.text.trim();
    final projectImageUrl = _projectImageUrlController.text.trim();
    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      projectUrl: projectUrl.isEmpty ? null : projectUrl,
      projectImageUrl: projectImageUrl.isEmpty ? null : projectImageUrl,
      isFeatured: _isFeatured,
    );

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Ringkasan Proyek',
      entries: [
        FormSummaryEntry(label: 'Nama Proyek', value: project.title),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: project.description,
          isMultiline: true,
        ),
        FormSummaryEntry(label: 'Kategori', value: project.category),
        FormSummaryEntry(label: 'Tautan Proyek', value: project.projectUrl),
        FormSummaryEntry(
          label: 'URL Gambar Proyek',
          value: project.projectImageUrl,
        ),
        FormSummaryEntry(
          label: 'Proyek Unggulan',
          value: project.isFeatured ? 'Ya' : 'Tidak',
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
                  onPressed: _submitForm,
                  child: const Text(
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
