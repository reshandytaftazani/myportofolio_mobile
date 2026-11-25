import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/widgets/form_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_form_scaffold.dart';

/// Halaman formulir untuk menambahkan entri Pendidikan baru.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage>
    with FormDraftStateMixin<EducationFormPage> {
  final _schoolNameController = TextEditingController();
  final _periodController = TextEditingController();
  final _detailController = TextEditingController();
  final _startYearController = TextEditingController();

  @override
  bool get isFormDirty =>
      _schoolNameController.text.isNotEmpty ||
      _periodController.text.isNotEmpty ||
      _detailController.text.isNotEmpty ||
      _startYearController.text.isNotEmpty;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _periodController.dispose();
    _detailController.dispose();
    _startYearController.dispose();
    super.dispose();
  }

  void _resetForm() {
    formKey.currentState?.reset();
    _schoolNameController.clear();
    _periodController.clear();
    _detailController.clear();
    _startYearController.clear();
    syncDirtyState();
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
    if (!formKey.currentState!.validate()) return;

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
    return buildFormScaffold(
      title: 'Tambah Pendidikan',
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
          validator: (value) =>
              validateRequiredText(value, fieldLabel: 'Periode', maxLength: 50),
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
        FilledButton(onPressed: _submitForm, child: const Text('Simpan')),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
