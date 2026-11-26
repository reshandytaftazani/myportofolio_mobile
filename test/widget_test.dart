import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

ApiClient _createMockApiClient() {
  return ApiClient(
    baseUrl: 'https://mock.local',
    client: MockClient((request) async {
      if (request.method == 'GET' &&
          const {
            '/api/v1/projects/',
            '/api/v1/experiences/',
            '/api/v1/education/',
            '/api/v1/skills/',
            '/api/v1/techstacks/',
          }.contains(request.url.path)) {
        return http.Response(jsonEncode([]), 200);
      }
      if (request.url.path == '/api/v1/projects/' && request.method == 'POST') {
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'mock-project-1',
            ...payload,
            'star_count': 0,
            'is_starred': false,
            'starred_by_names': '',
          }),
          201,
        );
      }
      if (request.url.path == '/api/v1/experiences/' &&
          request.method == 'POST') {
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'mock-experience-1',
            ...payload,
            'star_count': 0,
            'is_starred': false,
            'starred_by_names': '',
          }),
          201,
        );
      }
      if (request.url.path == '/api/v1/education/' &&
          request.method == 'POST') {
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 1,
            ...payload,
            'star_count': 0,
            'is_starred': false,
            'starred_by_names': '',
          }),
          201,
        );
      }
      if (request.url.path == '/api/v1/auth/token/' &&
          request.method == 'POST') {
        return http.Response(jsonEncode({'token': 'mock-token'}), 200);
      }
      if (request.url.path == '/api/v1/auth/logout/' &&
          request.method == 'POST') {
        return http.Response('', 204);
      }
      return http.Response('Not found', 404);
    }),
  );
}

Widget _wrapWithProviders(
  Widget child, {
  ApiClient? apiClient,
  String? initialToken,
}) {
  final client = apiClient ?? _createMockApiClient();
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: client),
      ChangeNotifierProvider<AuthState>(
        create: (_) => AuthState(client, initialToken: initialToken),
      ),
    ],
    child: child,
  );
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> saveForm(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Simpan');
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> submitExperienceForm(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Simpan');
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
    await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));
    await openDrawer(tester);
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioSectionPage), findsOneWidget);
    await openDrawer(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'project card pushes section, form and system Back returns home',
    (tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
      );
      await tester.ensureVisible(find.text('Projects'));
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Proyek').first);
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'form validates, summarizes all inputs and resets for another submission',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const MaterialApp(home: ProjectFormPage()),
          initialToken: 'test-token',
        ),
      );
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

      await tester.enterText(
        field('Nama Proyek'),
        List.filled(256, 'a').join(),
      );
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi valid');
      await tester.enterText(
        field('Tautan Proyek (Opsional)'),
        'https://example.com/${List.filled(185, 'p').join()}',
      );
      await tester.enterText(
        field('URL Gambar Proyek (Opsional)'),
        'https://example.com/${List.filled(485, 'i').join()}',
      );
      await saveForm(tester);
      expect(find.text('Nama proyek maksimal 255 karakter.'), findsOneWidget);
      expect(find.text('URL proyek maksimal 200 karakter.'), findsOneWidget);
      expect(
        find.text('URL gambar proyek maksimal 500 karakter.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('Nama Proyek'), 'Proyek A');
      await tester.enterText(
        field('Tautan Proyek (Opsional)'),
        'ftp://bad.example',
      );
      await tester.enterText(
        field('URL Gambar Proyek (Opsional)'),
        'not a url',
      );
      await saveForm(tester);
      expect(
        find.text('Gunakan URL HTTP/HTTPS yang valid dengan hostname.'),
        findsOneWidget,
      );
      expect(
        find.text('URL gambar proyek tidak boleh mengandung spasi.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('Nama Proyek'), 'Proyek A');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi A');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Tech Stack (Opsional)'), 'Flutter, Django');
      await tester.enterText(
        field('Tautan Proyek (Opsional)'),
        'https://example.com/project',
      );
      await tester.enterText(
        field('URL Gambar Proyek (Opsional)'),
        'https://example.com/cover.png',
      );
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      await saveForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek Berhasil Disimpan'), findsOneWidget);
      for (final text in [
        'Nama Proyek: Proyek A',
        'Kategori: Mobile Development',
        'Tech Stack: Flutter, Django',
        'Tautan Proyek: https://example.com/project',
        'URL Gambar Proyek: https://example.com/cover.png',
        'Proyek Unggulan: Ya',
      ]) {
        expect(find.textContaining(text), findsOneWidget);
      }
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Deskripsi A'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Edit Isian'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextFormField>(field('Nama Proyek')).controller?.text,
        'Proyek A',
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );

      await tester.enterText(field('Nama Proyek'), 'Proyek A Edit');
      await saveForm(tester);
      expect(find.textContaining('Nama Proyek: Proyek A Edit'), findsOneWidget);

      await tester.tap(find.text('Selesai'));
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
        Project.defaultCategory,
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );

      await tester.enterText(field('Nama Proyek'), 'Proyek B');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi B');
      await saveForm(tester);
      for (final text in [
        'Nama Proyek: Proyek B',
        'Kategori: Other',
        'Tautan Proyek: -',
        'URL Gambar Proyek: -',
        'Proyek Unggulan: Tidak',
      ]) {
        expect(find.textContaining(text), findsOneWidget);
      }
      await tester.tap(find.text('Selesai'));
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
        _wrapWithProviders(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const ProjectFormPage(),
          ),
          initialToken: 'test-token',
        ),
      );
      await openDrawer(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Projects'));
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Proyek').first);
      await tester.pumpAndSettle();
      await tester.enterText(field('Nama Proyek'), 'Proyek Ponsel');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi ponsel');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await saveForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.ensureVisible(find.text('Selesai'));
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'experience card and drawer open form, Back and Home return cleanly',
    (tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
      );

      await tester.ensureVisible(find.text('Experiences'));
      await tester.tap(find.text('Experiences'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Pengalaman').first);
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);

      await openDrawer(tester);
      await tester.tap(find.text('Experiences').last);
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioSectionPage), findsOneWidget);

      // Selecting the active page in drawer only closes the drawer.
      await openDrawer(tester);
      await tester.tap(find.text('Experiences').last);
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioSectionPage), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(PortfolioSectionPage), findsNothing);

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
      await tester.enterText(
        field('URL Thumbnail (Opsional)'),
        'ftp://bad url',
      );
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
      await tester.pumpWidget(
        _wrapWithProviders(
          const MaterialApp(home: ExperienceFormPage()),
          initialToken: 'test-token',
        ),
      );

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
      expect(find.text('Pengalaman Berhasil Disimpan'), findsOneWidget);
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

  testWidgets('experience form remains scrollable on phone with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      _wrapWithProviders(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ExperienceFormPage(),
        ),
        initialToken: 'test-token',
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
  });

  testWidgets(
    'education and skill cards and drawer open forms, Back and Home return cleanly',
    (tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
      );

      for (final entry in <(String, String, Type)>[
        ('Education', 'Tambah Pendidikan', EducationFormPage),
        ('Skills', 'Tambah Keahlian', SkillFormPage),
      ]) {
        final sectionLabel = entry.$1;
        final label = entry.$2;
        final pageType = entry.$3;

        await tester.ensureVisible(find.text(sectionLabel));
        await tester.tap(find.text(sectionLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(find.byType(pageType), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(pageType), findsNothing);

        await openDrawer(tester);
        await tester.ensureVisible(find.text(sectionLabel).last);
        await tester.tap(find.text(sectionLabel).last);
        await tester.pumpAndSettle();
        expect(find.byType(PortfolioSectionPage), findsOneWidget);

        // Selecting the active page in drawer only closes the drawer.
        await openDrawer(tester);
        await tester.ensureVisible(find.text(sectionLabel).last);
        await tester.tap(find.text(sectionLabel).last);
        await tester.pumpAndSettle();
        expect(find.byType(PortfolioSectionPage), findsOneWidget);

        await openDrawer(tester);
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(PortfolioSectionPage), findsNothing);

        final homeContext = tester.element(find.byType(MyHomePage));
        expect(Navigator.of(homeContext).canPop(), isFalse);
      }

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'education form validates whitespace, max lengths, 4-digit year, and Edit Isian',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const MaterialApp(home: EducationFormPage()),
          initialToken: 'test-token',
        ),
      );

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
      expect(find.text('Pendidikan Berhasil Disimpan'), findsOneWidget);
      expect(
        find.textContaining('Nama Sekolah / Institusi: Universitas Indonesia'),
        findsOneWidget,
      );
      expect(find.textContaining('Periode: 2024 - Sekarang'), findsOneWidget);
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
      expect(find.text('Nama keahlian maksimal 255 karakter.'), findsOneWidget);
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

  testWidgets(
    'tech stack card and drawer open form, Back and Home return cleanly',
    (tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
      );

      await tester.ensureVisible(find.text('Projects'));
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Tech Stack'));
      await tester.pumpAndSettle();
      expect(find.byType(TechStackFormPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(TechStackFormPage), findsNothing);

      await openDrawer(tester);
      await tester.ensureVisible(find.text('Projects').last);
      await tester.tap(find.text('Projects').last);
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioSectionPage), findsOneWidget);

      await openDrawer(tester);
      await tester.ensureVisible(find.text('Projects').last);
      await tester.tap(find.text('Projects').last);
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioSectionPage), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(PortfolioSectionPage), findsNothing);

      final homeContext = tester.element(find.byType(MyHomePage));
      expect(Navigator.of(homeContext).canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tech stack form validates invalid URL, decimal order, empty snippet, and preserves multiline summary',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TechStackFormPage()));

      expect(
        tester.widget<TextFormField>(field('Urutan Tampil')).controller?.text,
        '0',
      );

      await tester.enterText(field('Nama Tech Stack'), '   ');
      await tester.enterText(field('URL Ikon'), 'ftp://invalid.example');
      await tester.enterText(field('Nama File'), '   ');
      await tester.enterText(field('Cuplikan Kode'), '   ');
      await tester.enterText(field('Urutan Tampil'), '1.5');
      await submitExperienceForm(tester);

      expect(find.text('Nama tech stack tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Gunakan URL HTTP/HTTPS yang valid dengan hostname.'),
        findsOneWidget,
      );
      expect(find.text('Nama file tidak boleh kosong.'), findsOneWidget);
      expect(find.text('Cuplikan kode tidak boleh kosong.'), findsOneWidget);
      expect(
        find.text('Urutan tampil harus berupa bilangan bulat.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      const snippet = 'class DartStack {\n  final int version = 3;\n}';
      await tester.enterText(field('Nama Tech Stack'), 'Dart');
      await tester.enterText(
        field('URL Ikon'),
        'https://cdn.example.com/dart.svg',
      );
      await tester.enterText(field('Nama File'), 'dart_stack.dart');
      await tester.enterText(field('Cuplikan Kode'), snippet);
      await tester.enterText(field('Urutan Tampil'), '2');
      await submitExperienceForm(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Ringkasan Tech Stack'), findsOneWidget);
      expect(find.textContaining('Nama Tech Stack: Dart'), findsOneWidget);
      expect(
        find.textContaining('URL Ikon: https://cdn.example.com/dart.svg'),
        findsOneWidget,
      );
      expect(find.textContaining('Nama File: dart_stack.dart'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(snippet),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Urutan Tampil: 2'), findsOneWidget);

      await tester.tap(find.text('Edit Isian'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextFormField>(field('Cuplikan Kode')).controller?.text,
        snippet,
      );

      await submitExperienceForm(tester);
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextFormField>(field('Nama Tech Stack')).controller?.text,
        isEmpty,
      );
      expect(
        tester.widget<TextFormField>(field('Urutan Tampil')).controller?.text,
        '0',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tech stack summary dialog scrolls long code snippet on narrow phone and keeps actions reachable',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(const MaterialApp(home: TechStackFormPage()));

      final longSnippet = List.generate(
        40,
        (i) => '  final line$i = "value_$i";',
      ).join('\n');

      await tester.enterText(field('Nama Tech Stack'), 'Flutter');
      await tester.enterText(
        field('URL Ikon'),
        'https://cdn.example.com/flutter.svg',
      );
      await tester.enterText(field('Nama File'), 'main.dart');
      await tester.enterText(field('Cuplikan Kode'), longSnippet);
      await tester.enterText(field('Urutan Tampil'), '1');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      await submitExperienceForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);

      final dialogScroll = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(SingleChildScrollView),
      );
      await tester.drag(dialogScroll, const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Selesai'));
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  group('AuthState & ensureLoggedIn guard', () {
    test(
      'AuthState login and logout update token and notify listeners',
      () async {
        var notifyCount = 0;
        String? logoutAuthHeader;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/auth/token/') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              if (body['username'] == 'admin' && body['password'] == 'secret') {
                return http.Response(jsonEncode({'token': 'tok-123'}), 200);
              }
              return http.Response(jsonEncode({'detail': 'Invalid'}), 400);
            }
            if (request.url.path == '/api/v1/auth/logout/') {
              logoutAuthHeader = request.headers['Authorization'];
              return http.Response('', 204);
            }
            return http.Response('Not found', 404);
          }),
        );

        final authState = AuthState(apiClient);
        authState.addListener(() => notifyCount++);

        expect(authState.isLoggedIn, isFalse);
        expect(authState.token, isNull);

        await authState.login('admin', 'secret');
        expect(authState.isLoggedIn, isTrue);
        expect(authState.token, 'tok-123');
        expect(notifyCount, 1);

        await authState.logout();
        expect(logoutAuthHeader, 'Token tok-123');
        expect(authState.isLoggedIn, isFalse);
        expect(authState.token, isNull);
        expect(notifyCount, 2);
      },
    );

    testWidgets(
      'ensureLoggedIn redirects unauthenticated user to LoginScreen and proceeds after login',
      (tester) async {
        await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tambah Proyek').first);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ProjectFormPage), findsNothing);

        await tester.enterText(field('Username'), 'admin');
        await tester.enterText(field('Password'), 'secret');
        await tester.tap(find.widgetWithText(FilledButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(ProjectFormPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ensureLoggedIn returns true immediately when already logged in',
      (tester) async {
        bool? result;
        await tester.pumpWidget(
          _wrapWithProviders(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await ensureLoggedIn(context);
                    },
                    child: const Text('Check Guard'),
                  ),
                ),
              ),
            ),
            initialToken: 'existing-token',
          ),
        );

        await tester.tap(find.text('Check Guard'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });
}
