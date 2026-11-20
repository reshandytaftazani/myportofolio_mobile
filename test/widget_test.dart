import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> saveForm(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Future<void> submitExperienceForm(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> pickDay(WidgetTester tester, String label, String day) async {
  await tester.ensureVisible(field(label));
  await tester.pumpAndSettle();
  await tester.tap(field(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(day).last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

void main() {
  testWidgets('drawer renders without overflow and navigates both ways', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await openDrawer(tester);
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await openDrawer(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('project card pushes form and system Back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.tap(find.text('TUTUP'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'form validates, summarizes all inputs and resets for another submission',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
      await saveForm(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.enterText(field('Deskripsi Proyek'), '   ');
      await saveForm(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(field('Nama Proyek'), 'Proyek A');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi A');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Teknologi yang Digunakan'), 'Flutter');
      await tester.enterText(field('Tautan Proyek'), 'https://example.com');
      await saveForm(tester);
      for (final text in [
        'Nama Proyek: Proyek A',
        'Deskripsi: Deskripsi A',
        'Kategori: Mobile Development',
        'Teknologi: Flutter',
        'Tautan: https://example.com',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .value,
        'Web Development',
      );
      await tester.enterText(field('Nama Proyek'), 'Proyek B');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi B');
      await saveForm(tester);
      for (final text in [
        'Nama Proyek: Proyek B',
        'Deskripsi: Deskripsi B',
        'Kategori: Web Development',
        'Teknologi: ',
        'Tautan: ',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phone form remains scrollable with keyboard and drawer supports large text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ProjectFormPage(),
        ),
      );
      await openDrawer(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Add Project'));
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nama Proyek'), 'Proyek Ponsel');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi ponsel');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await saveForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'experience card and drawer open form, Back and Home return cleanly',
    (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.ensureVisible(find.text('Tambah Pengalaman'));
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await tester.tap(find.text('TUTUP'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);

      await openDrawer(tester);
      await tester.tap(find.text('Tambah Pengalaman').last);
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      // Selecting the active page in drawer only closes the drawer.
      await openDrawer(tester);
      await tester.tap(find.text('Tambah Pengalaman').last);
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);

      // Ensure Home did not push a duplicate route.
      final homeContext = tester.element(find.byType(MyHomePage));
      expect(Navigator.of(homeContext).canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'experience form validates required text, URL, and reversed dates',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

      await submitExperienceForm(tester);
      expect(find.text('Nama pengalaman tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Deskripsi pengalaman tidak boleh kosong.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('Nama Pengalaman'), '   ');
      await tester.enterText(field('Deskripsi Pengalaman'), '   ');
      await tester.enterText(field('URL Thumbnail (Opsional)'), 'ftp://bad url');
      await submitExperienceForm(tester);
      expect(find.text('Nama pengalaman tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Deskripsi pengalaman tidak boleh kosong.'),
        findsOneWidget,
      );
      expect(
        find.text('URL thumbnail tidak boleh mengandung spasi.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('Nama Pengalaman'), 'Backend Intern');
      await tester.enterText(field('Deskripsi Pengalaman'), 'Membangun API');
      await tester.enterText(
        field('URL Thumbnail (Opsional)'),
        'https://example.com/thumb.png',
      );
      await pickDay(tester, 'Tanggal Mulai (Opsional)', '15');
      await pickDay(tester, 'Tanggal Selesai (Opsional)', '10');
      await submitExperienceForm(tester);
      expect(
        find.text(
          'Tanggal selesai harus sama dengan atau setelah tanggal mulai.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'experience summary displays all inputs, Edit Isian preserves values, and Selesai resets',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

      await tester.enterText(
        field('Nama Pengalaman'),
        'Software Engineer Intern',
      );
      await tester.enterText(
        field('Perusahaan / Organisasi (Opsional)'),
        'PT Maju',
      );
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        field('Deskripsi Pengalaman'),
        'Mengembangkan fitur mobile',
      );
      await tester.enterText(
        field('URL Thumbnail (Opsional)'),
        'https://example.com/img.png',
      );
      await pickDay(tester, 'Tanggal Mulai (Opsional)', '10');
      await pickDay(tester, 'Tanggal Selesai (Opsional)', '15');

      await submitExperienceForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Ringkasan Pengalaman'), findsOneWidget);
      for (final expected in [
        'Nama Pengalaman: Software Engineer Intern',
        'Perusahaan / Organisasi: PT Maju',
        'Kategori: Internship',
        'URL Thumbnail: https://example.com/img.png',
      ]) {
        expect(find.textContaining(expected), findsOneWidget);
      }
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Mengembangkan fitur mobile'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Edit Isian'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      expect(
        tester.widget<TextFormField>(field('Nama Pengalaman')).controller?.text,
        'Software Engineer Intern',
      );
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .value,
        'internship',
      );

      await tester.enterText(field('Nama Pengalaman'), 'Senior Intern');
      await submitExperienceForm(tester);
      expect(
        find.textContaining('Nama Pengalaman: Senior Intern'),
        findsOneWidget,
      );

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .value,
        Experience.defaultCategory,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'experience form remains scrollable on phone with keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ExperienceFormPage(),
        ),
      );

      await tester.enterText(field('Nama Pengalaman'), 'Mobile Dev');
      await tester.enterText(field('Deskripsi Pengalaman'), 'Build Flutter UI');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      await submitExperienceForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'education and skill cards and drawer open forms, Back and Home return cleanly',
    (tester) async {
      await tester.pumpWidget(const MyApp());

      for (final entry in <(String, Type)>[
        ('Tambah Pendidikan', EducationFormPage),
        ('Tambah Keahlian', SkillFormPage),
      ]) {
        final label = entry.$1;
        final pageType = entry.$2;

        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(pageType), findsOneWidget);

        await tester.tap(find.text('TUTUP'));
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(pageType), findsNothing);

        await openDrawer(tester);
        await tester.ensureVisible(find.text(label).last);
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(find.byType(pageType), findsOneWidget);

        // Selecting the active page in drawer only closes the drawer.
        await openDrawer(tester);
        await tester.ensureVisible(find.text(label).last);
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(find.byType(pageType), findsOneWidget);

        await openDrawer(tester);
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(pageType), findsNothing);

        final homeContext = tester.element(find.byType(MyHomePage));
        expect(Navigator.of(homeContext).canPop(), isFalse);
      }

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'education form validates whitespace, max lengths, 4-digit year, and Edit Isian',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      await tester.enterText(field('Nama Sekolah / Institusi'), '   ');
      await tester.enterText(field('Periode'), '   ');
      await tester.enterText(field('Detail Pendidikan'), '   ');
      await tester.enterText(field('Tahun Mulai'), '   ');
      await submitExperienceForm(tester);

      expect(
        find.text('Nama sekolah/institusi tidak boleh kosong.'),
        findsOneWidget,
      );
      expect(find.text('Periode tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Detail pendidikan tidak boleh kosong.'),
        findsOneWidget,
      );
      expect(find.text('Tahun mulai tidak boleh kosong.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(
        field('Nama Sekolah / Institusi'),
        List.filled(256, 'a').join(),
      );
      await tester.enterText(field('Periode'), List.filled(51, 'b').join());
      await tester.enterText(
        field('Detail Pendidikan'),
        List.filled(256, 'c').join(),
      );
      for (final badYear in ['abcd', '999', '20240', '-2024', '0000']) {
        await tester.enterText(field('Tahun Mulai'), badYear);
        await submitExperienceForm(tester);
        expect(
          find.text('Tahun mulai harus berupa bilangan bulat positif 4 digit.'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      }
      expect(
        find.text('Nama sekolah/institusi maksimal 255 karakter.'),
        findsOneWidget,
      );
      expect(find.text('Periode maksimal 50 karakter.'), findsOneWidget);
      expect(
        find.text('Detail pendidikan maksimal 255 karakter.'),
        findsOneWidget,
      );

      await tester.enterText(
        field('Nama Sekolah / Institusi'),
        'Universitas Indonesia',
      );
      await tester.enterText(field('Periode'), '2024 - Sekarang');
      await tester.enterText(field('Detail Pendidikan'), 'S1 Ilmu Komputer');
      await tester.enterText(field('Tahun Mulai'), '2024');
      await submitExperienceForm(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Ringkasan Pendidikan'), findsOneWidget);
      expect(
        find.textContaining('Nama Sekolah / Institusi: Universitas Indonesia'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Periode: 2024 - Sekarang'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('S1 Ilmu Komputer'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Tahun Mulai: 2024'), findsOneWidget);

      await tester.tap(find.text('Edit Isian'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester
            .widget<TextFormField>(field('Nama Sekolah / Institusi'))
            .controller
            ?.text,
        'Universitas Indonesia',
      );
      expect(
        tester.widget<TextFormField>(field('Tahun Mulai')).controller?.text,
        '2024',
      );

      await tester.enterText(field('Tahun Mulai'), '2025');
      await submitExperienceForm(tester);
      expect(find.textContaining('Tahun Mulai: 2025'), findsOneWidget);

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'skill form validates whitespace, max lengths, and preserves code snippet indentation on Edit Isian',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SkillFormPage()));

      await tester.enterText(field('Nama Keahlian'), '   ');
      await tester.enterText(field('Level'), '   ');
      await tester.enterText(field('Deskripsi Keahlian'), '   ');
      await submitExperienceForm(tester);

      expect(find.text('Nama keahlian tidak boleh kosong.'), findsOneWidget);
      expect(find.text('Level tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Deskripsi keahlian tidak boleh kosong.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(
        field('Nama Keahlian'),
        List.filled(256, 'a').join(),
      );
      await tester.enterText(field('Level'), List.filled(51, 'b').join());
      await tester.enterText(field('Deskripsi Keahlian'), 'Valid description');
      await submitExperienceForm(tester);
      expect(
        find.text('Nama keahlian maksimal 255 karakter.'),
        findsOneWidget,
      );
      expect(find.text('Level maksimal 50 karakter.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      const snippet = 'void main() {\n  print("Hello");\n}';
      await tester.enterText(field('Nama Keahlian'), 'Flutter & Dart');
      await tester.enterText(field('Level'), 'Intermediate');
      await tester.enterText(
        field('Deskripsi Keahlian'),
        'Membangun UI responsif',
      );
      await tester.enterText(field('Cuplikan Kode (Opsional)'), snippet);
      await submitExperienceForm(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Ringkasan Keahlian'), findsOneWidget);
      expect(
        find.textContaining('Nama Keahlian: Flutter & Dart'),
        findsOneWidget,
      );
      expect(find.textContaining('Level: Intermediate'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Membangun UI responsif'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(snippet),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Edit Isian'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextFormField>(field('Nama Keahlian')).controller?.text,
        'Flutter & Dart',
      );
      expect(
        tester
            .widget<TextFormField>(field('Cuplikan Kode (Opsional)'))
            .controller
            ?.text,
        snippet,
      );

      await tester.enterText(field('Level'), 'Advanced');
      await submitExperienceForm(tester);
      expect(find.textContaining('Level: Advanced'), findsOneWidget);

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
