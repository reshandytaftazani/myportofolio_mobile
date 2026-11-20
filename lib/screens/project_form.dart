import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/project.dart';
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
    });
  }

  void _submitForm() {
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama Proyek: ${project.title}'),
                Text('Deskripsi: ${project.description}'),
                Text('Kategori: ${project.category}'),
                Text('Tautan: ${project.projectUrl ?? '-'}'),
                Text('URL Gambar: ${project.projectImageUrl ?? '-'}'),
                Text('Unggulan: ${project.isFeatured ? 'Ya' : 'Tidak'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Project Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _fieldDecoration(
                  labelText: 'Nama Proyek',
                  hintText: 'Nama Proyek',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Nama proyek tidak boleh kosong!';
                  }
                  if (trimmed.length > 255) {
                    return 'Nama proyek maksimal 255 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                minLines: 3,
                decoration: _fieldDecoration(
                  labelText: 'Deskripsi Proyek',
                  hintText: 'Deskripsi Proyek',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi proyek tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _category,
                decoration: _fieldDecoration(labelText: 'Kategori Proyek'),
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
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _projectUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
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
                decoration: _fieldDecoration(
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
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
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
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
