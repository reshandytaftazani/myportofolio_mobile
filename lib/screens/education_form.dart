import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan entri Pendidikan baru.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _schoolNameController = TextEditingController();
  final _periodController = TextEditingController();
  final _detailController = TextEditingController();
  final _startYearController = TextEditingController();

  bool _wasDirty = false;

  bool get _isDirty =>
      _schoolNameController.text.isNotEmpty ||
      _periodController.text.isNotEmpty ||
      _detailController.text.isNotEmpty ||
      _startYearController.text.isNotEmpty;

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
    _schoolNameController.dispose();
    _periodController.dispose();
    _detailController.dispose();
    _startYearController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _schoolNameController.clear();
    _periodController.clear();
    _detailController.clear();
    _startYearController.clear();
    _syncDirtyState();
  }

  String? _validateStartYear(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Tahun mulai tidak boleh kosong.';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      return 'Tahun mulai harus berupa bilangan bulat positif 4 digit.';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1000) {
      return 'Tahun mulai harus berupa bilangan bulat positif 4 digit.';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final education = Education(
      schoolName: _schoolNameController.text.trim(),
      period: _periodController.text.trim(),
      detail: _detailController.text.trim(),
      startYear: int.parse(_startYearController.text.trim()),
    );

    final shouldReset = await showFormSummaryDialog(
      context: context,
      title: 'Ringkasan Pendidikan',
      entries: [
        FormSummaryEntry(
          label: 'Nama Sekolah / Institusi',
          value: education.schoolName,
        ),
        FormSummaryEntry(label: 'Periode', value: education.period),
        FormSummaryEntry(
          label: 'Detail',
          value: education.detail,
          isMultiline: true,
        ),
        FormSummaryEntry(
          label: 'Tahun Mulai',
          value: education.startYear.toString(),
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
            'Tambah Pendidikan',
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
                  controller: _schoolNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Sekolah / Institusi',
                    hintText: 'Contoh: Universitas Indonesia',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Nama sekolah/institusi',
                    maxLength: 255,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _periodController,
                  decoration: const InputDecoration(
                    labelText: 'Periode',
                    hintText: 'Contoh: 2024 - Sekarang',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Periode',
                    maxLength: 50,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _detailController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Detail Pendidikan',
                    hintText: 'Contoh: S1 Ilmu Komputer',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateRequiredText(
                    value,
                    fieldLabel: 'Detail pendidikan',
                    maxLength: 255,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _startYearController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Tahun Mulai',
                    hintText: 'Contoh: 2024',
                  ),
                  validator: _validateStartYear,
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
