import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan entri Pengalaman baru.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startedAtController = TextEditingController();
  final _endedAtController = TextEditingController();

  String _category = Experience.defaultCategory;
  DateTime? _startedAt;
  DateTime? _endedAt;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _startedAtController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startedAt ?? _endedAt ?? DateTime.now())
        : (_endedAt ?? _startedAt ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startedAtController.text = _formatDate(picked);
      } else {
        _endedAt = picked;
        _endedAtController.text = _formatDate(picked);
      }
    });
  }

  void _clearDate({required bool isStart}) {
    setState(() {
      if (isStart) {
        _startedAt = null;
        _startedAtController.clear();
      } else {
        _endedAt = null;
        _endedAtController.clear();
      }
    });
  }

  String? _validateThumbnailUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    if (trimmed.length > 200) {
      return 'URL thumbnail maksimal 200 karakter.';
    }
    if (trimmed.contains(RegExp(r'\s'))) {
      return 'URL thumbnail tidak boleh mengandung spasi.';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Gunakan URL HTTP/HTTPS yang valid dengan hostname.';
    }
    return null;
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required DateTime? selectedDate,
    required bool isStart,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(isStart: isStart),
      decoration: _fieldDecoration(
        labelText: labelText,
        hintText: 'YYYY-MM-DD',
        suffixIcon: selectedDate == null
            ? const Icon(Icons.calendar_today)
            : IconButton(
                tooltip: 'Hapus tanggal',
                icon: const Icon(Icons.clear),
                onPressed: () => _clearDate(isStart: isStart),
              ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pengalaman',
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
                  labelText: 'Nama Pengalaman',
                  hintText: 'Contoh: Software Engineer Intern',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Nama pengalaman tidak boleh kosong.';
                  }
                  if (trimmed.length > 255) {
                    return 'Nama pengalaman maksimal 255 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _companyController,
                decoration: _fieldDecoration(
                  labelText: 'Perusahaan / Organisasi (Opsional)',
                  hintText: 'Contoh: Google',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.length > 255) {
                    return 'Nama perusahaan/organisasi maksimal 255 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _category,
                decoration: _fieldDecoration(labelText: 'Kategori'),
                items: Experience.categoryChoices.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
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
                controller: _descriptionController,
                maxLines: 5,
                minLines: 3,
                decoration: _fieldDecoration(
                  labelText: 'Deskripsi Pengalaman',
                  hintText: 'Ceritakan peran dan pencapaianmu',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Deskripsi pengalaman tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _thumbnailController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  labelText: 'URL Thumbnail (Opsional)',
                  hintText: 'https://example.com/image.png',
                ),
                validator: _validateThumbnailUrl,
              ),
              const SizedBox(height: 16.0),
              _buildDateField(
                controller: _startedAtController,
                labelText: 'Tanggal Mulai (Opsional)',
                selectedDate: _startedAt,
                isStart: true,
              ),
              const SizedBox(height: 16.0),
              _buildDateField(
                controller: _endedAtController,
                labelText: 'Tanggal Selesai (Opsional)',
                selectedDate: _endedAt,
                isStart: false,
                validator: (_) {
                  if (_startedAt != null &&
                      _endedAt != null &&
                      _endedAt!.isBefore(_startedAt!)) {
                    return 'Tanggal selesai harus sama dengan atau setelah tanggal mulai.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Isian pengalaman valid.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Simpan',
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
