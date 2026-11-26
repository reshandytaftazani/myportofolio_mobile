import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/authenticated_action_helper.dart';
import 'package:myportofolio_mobile/utils/date_formatter.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_form_scaffold.dart';

/// Halaman formulir untuk menambahkan entri Pengalaman baru.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage>
    with FormDraftStateMixin<ExperienceFormPage> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startedAtController = TextEditingController();
  final _endedAtController = TextEditingController();

  String _category = Experience.defaultCategory;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isSubmitting = false;
  bool _hasCreatedExperience = false;

  @override
  bool get isFormDirty =>
      _titleController.text.isNotEmpty ||
      _companyController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _thumbnailController.text.isNotEmpty ||
      _category != Experience.defaultCategory ||
      _startedAt != null ||
      _endedAt != null;

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

    setFormState(() {
      if (isStart) {
        _startedAt = picked;
        _startedAtController.text = formatIsoDate(picked);
      } else {
        _endedAt = picked;
        _endedAtController.text = formatIsoDate(picked);
      }
    });
  }

  void _clearDate({required bool isStart}) {
    setFormState(() {
      if (isStart) {
        _startedAt = null;
        _startedAtController.clear();
      } else {
        _endedAt = null;
        _endedAtController.clear();
      }
    });
  }

  void _resetForm() {
    formKey.currentState?.reset();
    _titleController.clear();
    _companyController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _startedAtController.clear();
    _endedAtController.clear();
    setFormState(() {
      _category = Experience.defaultCategory;
      _startedAt = null;
      _endedAt = null;
    });
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

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

    final result = await runAuthenticatedAction<Experience>(
      context: context,
      action: (apiClient, token) =>
          apiClient.createExperience(experience, token: token),
      errorActionLabel: 'Gagal menyimpan pengalaman',
      reLoginSuccessMessage:
          'Login berhasil. Tekan Simpan untuk mengirim ulang pengalaman.',
      onSubmittingChanged: (isSubmitting) {
        setState(() {
          _isSubmitting = isSubmitting;
        });
      },
    );

    if (!result.succeeded || !mounted) return;
    final created = result.data!;

    setState(() {
      _hasCreatedExperience = true;
    });

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Pengalaman Berhasil Disimpan',
      entries: [
        FormSummaryEntry(label: 'Nama Pengalaman', value: created.title),
        FormSummaryEntry(
          label: 'Perusahaan / Organisasi',
          value: created.company,
        ),
        FormSummaryEntry(label: 'Kategori', value: created.categoryLabel),
        FormSummaryEntry(
          label: 'Deskripsi',
          value: created.description,
          isMultiline: true,
        ),
        FormSummaryEntry(label: 'URL Thumbnail', value: created.thumbnail),
        FormSummaryEntry(
          label: 'Tanggal Mulai',
          value: created.startedAt != null
              ? formatIsoDate(created.startedAt!)
              : null,
        ),
        FormSummaryEntry(
          label: 'Tanggal Selesai',
          value: created.endedAt != null
              ? formatIsoDate(created.endedAt!)
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
      enabled: !_isSubmitting,
      readOnly: true,
      onTap: _isSubmitting ? null : () => _pickDate(isStart: isStart),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'YYYY-MM-DD',
        suffixIcon: selectedDate == null
            ? const Icon(Icons.calendar_today)
            : IconButton(
                tooltip: 'Hapus tanggal',
                icon: const Icon(Icons.clear),
                onPressed: _isSubmitting
                    ? null
                    : () => _clearDate(isStart: isStart),
              ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFormScaffold(
      title: 'Tambah Pengalaman',
      popResult: _hasCreatedExperience ? true : null,
      children: [
        TextFormField(
          controller: _titleController,
          enabled: !_isSubmitting,
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
          enabled: !_isSubmitting,
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
          controller: _descriptionController,
          enabled: !_isSubmitting,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            labelText: 'Deskripsi Pengalaman',
            hintText: 'Ceritakan peran dan pencapaianmu',
          ),
          validator: (value) =>
              validateRequiredText(value, fieldLabel: 'Deskripsi pengalaman'),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _thumbnailController,
          enabled: !_isSubmitting,
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
