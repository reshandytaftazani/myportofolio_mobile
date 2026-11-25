import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
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
  bool _wasDirty = false;

  bool get _isDirty =>
      _titleController.text.isNotEmpty ||
      _companyController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _thumbnailController.text.isNotEmpty ||
      _category != Experience.defaultCategory ||
      _startedAt != null ||
      _endedAt != null;

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
      _wasDirty = _isDirty;
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
      _wasDirty = _isDirty;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _companyController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _startedAtController.clear();
    _endedAtController.clear();
    setState(() {
      _category = Experience.defaultCategory;
      _startedAt = null;
      _endedAt = null;
      _wasDirty = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final company = _companyController.text.trim();
    final thumbnail = _thumbnailController.text.trim();
    final experience = Experience(
      title: _titleController.text.trim(),
      company: company.isEmpty ? null : company,
      description: _descriptionController.text.trim(),
      category: _category,
      thumbnail: thumbnail.isEmpty ? null : thumbnail,
      startedAt: _startedAt,
      endedAt: _endedAt,
    );

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Ringkasan Pengalaman',
      entries: [
        FormSummaryEntry(label: 'Nama Pengalaman', value: experience.title),
        FormSummaryEntry(
          label: 'Perusahaan / Organisasi',
          value: experience.company,
        ),
        FormSummaryEntry(label: 'Kategori', value: experience.categoryLabel),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: experience.description,
          isMultiline: true,
        ),
        FormSummaryEntry(label: 'URL Thumbnail', value: experience.thumbnail),
        FormSummaryEntry(
          label: 'Tanggal Mulai',
          value: experience.startedAt != null
              ? _formatDate(experience.startedAt!)
              : null,
        ),
        FormSummaryEntry(
          label: 'Tanggal Selesai',
          value: experience.endedAt != null
              ? _formatDate(experience.endedAt!)
              : null,
        ),
      ],
    );

    if (shouldReset == true && mounted) {
      _resetForm();
    }
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
      decoration: InputDecoration(
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

    return FormDraftPopScope(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tambah Pengalaman',
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
                    labelText: 'Nama Pengalaman',
                    hintText: 'Contoh: Software Engineer Intern',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Nama pengalaman',
                    maxLength: 255,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(labelText: 'Kategori'),
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
                      _wasDirty = _isDirty;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Pengalaman',
                    hintText: 'Ceritakan peran dan pencapaianmu',
                  ),
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Deskripsi pengalaman',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _thumbnailController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'URL Thumbnail (Opsional)',
                    hintText: 'https://example.com/image.png',
                  ),
                  validator: (value) =>
                      validateHttpUrl(value, fieldLabel: 'URL thumbnail'),
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
                  onPressed: _submitForm,
                  child: const Text(
                    'Simpan',
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
