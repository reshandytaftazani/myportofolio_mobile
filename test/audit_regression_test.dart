import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_menu.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/url_launcher_helper.dart';
import 'package:myportofolio_mobile/widgets/experience_card.dart';
import 'package:myportofolio_mobile/widgets/project_item_card.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';
import 'package:myportofolio_mobile/widgets/tech_stack_card.dart';

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
      return http.Response('Not found', 404);
    }),
  );
}

class _FakeHttpOverrides extends HttpOverrides {
  final Map<String, ({int statusCode, List<int> bytes})> responses;
  int closedClientCount = 0;

  _FakeHttpOverrides(this.responses);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient(responses, onClose: () => closedClientCount++);
  }
}

class _FakeHttpClient implements HttpClient {
  final Map<String, ({int statusCode, List<int> bytes})> responses;
  final VoidCallback onClose;

  _FakeHttpClient(this.responses, {required this.onClose});

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final entry =
        responses[url.toString()] ??
        (statusCode: HttpStatus.notFound, bytes: <int>[]);
    return _FakeHttpClientRequest(entry.statusCode, entry.bytes);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => getUrl(url);

  @override
  void close({bool force = false}) {
    onClose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final List<int> bytes;

  _FakeHttpClientRequest(this.statusCode, this.bytes);

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse(statusCode, bytes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> _bytes;

  _FakeHttpClientResponse(this.statusCode, this._bytes);

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Home layout overflow regression', () {
    for (final width in [320.0, 360.0, 390.0, 400.0]) {
      testWidgets('MyHomePage renders without overflow at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));
        await tester.pumpAndSettle();

        expect(find.text('Active Student'), findsOneWidget);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Experiences'), findsOneWidget);
        expect(find.text('Education'), findsOneWidget);
        expect(find.text('Skills'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'MyHomePage renders without overflow on narrow phone with large text scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Active Student'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Experience date status consistency', () {
    testWidgets(
      'startedAt without endedAt and isOngoing == false shows Belum diisi in card and detail',
      (tester) async {
        final exp = Experience(
          title: 'Research Assistant',
          description: 'Meneliti pemrosesan bahasa alami.',
          startedAt: DateTime(2025, 2, 1),
          endedAt: null,
          isOngoing: false,
        );

        expect(exp.endStatus, ExperienceEndStatus.unknown);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Feb 2025 – Belum diisi'), findsOneWidget);
        expect(find.textContaining('Sekarang'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('1 Februari 2025'), findsOneWidget);
        expect(find.text('Belum diisi'), findsOneWidget);
        expect(find.textContaining('Sekarang'), findsNothing);
      },
    );

    testWidgets(
      'isOngoing == true shows Sekarang in card and Sekarang (Ongoing) in detail',
      (tester) async {
        final exp = Experience(
          title: 'Teaching Assistant',
          description: 'Mengajar kelas praktikum.',
          startedAt: DateTime(2025, 8, 1),
          endedAt: null,
          isOngoing: true,
        );

        expect(exp.endStatus, ExperienceEndStatus.ongoing);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Agu 2025 – Sekarang'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('1 Agustus 2025'), findsOneWidget);
        expect(find.text('Sekarang (Ongoing)'), findsOneWidget);
      },
    );

    testWidgets(
      'completed experience shows formatted end date in both card and detail',
      (tester) async {
        final exp = Experience(
          title: 'Mobile Intern',
          description: 'Mengembangkan aplikasi Flutter.',
          startedAt: DateTime(2025, 1, 10),
          endedAt: DateTime(2025, 5, 30),
          isOngoing: false,
        );

        expect(exp.endStatus, ExperienceEndStatus.completed);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Jan 2025 – Mei 2025'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('10 Januari 2025'), findsOneWidget);
        expect(find.text('30 Mei 2025'), findsOneWidget);
      },
    );
  });

  group('Portfolio section decoupling and empty state', () {
    testWidgets(
      'buildPortfolioMenuItems supports injected empty PortfolioDataSource',
      (tester) async {
        final emptyMenus = buildPortfolioMenuItems(
          dataSource: const PortfolioDataSource(),
        );
        final projectsMenu = emptyMenus.firstWhere(
          (item) => item.section == PortfolioSection.projects,
        );

        await tester.pumpWidget(
          MaterialApp(home: Builder(builder: projectsMenu.pageBuilder)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(find.text('Belum ada data Projects'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Shared form validator', () {
    test(
      'validateRequiredText handles empty, whitespace, maxLength, and suffix',
      () {
        expect(
          validateRequiredText(null, fieldLabel: 'Judul'),
          'Judul tidak boleh kosong.',
        );
        expect(
          validateRequiredText('   ', fieldLabel: 'Judul', emptySuffix: '!'),
          'Judul tidak boleh kosong!',
        );
        expect(
          validateRequiredText('abcdef', fieldLabel: 'Judul', maxLength: 5),
          'Judul maksimal 5 karakter.',
        );
        expect(
          validateRequiredText('abcde', fieldLabel: 'Judul', maxLength: 5),
          isNull,
        );
      },
    );
  });

  group('Verdict 1: Draft protection & drawer route reuse', () {
    testWidgets(
      'selecting Projects from filled form asks confirmation, preserves draft on Batal, and reuses existing Projects route on Buang',
      (tester) async {
        await tester.pumpWidget(
          MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
        );

        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        expect(find.byType(PortfolioSectionPage), findsOneWidget);

        await tester.tap(find.text('Tambah Proyek').first);
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);

        // Isi draf pada form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'Draf Proyek Penting',
        );
        await tester.pump();

        // Tekan tombol Back sistem -> harus muncul dialog konfirmasi
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsOneWidget);

        // Pilih Batal -> tetap di form dan draf masih utuh
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);
        expect(find.text('Draf Proyek Penting'), findsOneWidget);

        // Buka drawer dari form yang sudah diisi, lalu pilih Projects
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Projects').last);
        await tester.pumpAndSettle();

        // Dialog konfirmasi harus muncul
        expect(find.text('Buang Perubahan Draf?'), findsOneWidget);

        // Pilih Batal -> masih di ProjectFormPage dan teks tidak hilang
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);
        expect(find.text('Draf Proyek Penting'), findsOneWidget);

        // Buka drawer lagi, pilih Projects, lalu konfirmasi Buang
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Projects').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buang'));
        await tester.pumpAndSettle();

        // Kembali ke halaman Projects yang sudah terbuka
        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(find.byType(ProjectFormPage), findsNothing);

        // Satu kali Back harus langsung kembali ke MyHomePage (tidak ada dua layar Projects berturut-turut)
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(PortfolioSectionPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'TechStackFormPage, EducationFormPage, and SkillFormPage clear dirty state after reset so Back pops without discard dialog',
      (tester) async {
        // 1. TechStackFormPage
        await tester.pumpWidget(
          MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
        );
        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tambah Tech Stack'));
        await tester.pumpAndSettle();
        expect(find.byType(TechStackFormPage), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Tech Stack'),
          'Dart',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'URL Ikon'),
          'https://cdn.example.com/dart.svg',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama File'),
          'main.dart',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Cuplikan Kode'),
          'void main() {}',
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsNothing);
        expect(find.byType(TechStackFormPage), findsNothing);

        // Kembali ke Home sebelum menguji form berikutnya
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 2. EducationFormPage
        await tester.ensureVisible(find.text('Education'));
        await tester.tap(find.text('Education'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tambah Pendidikan').first);
        await tester.pumpAndSettle();
        expect(find.byType(EducationFormPage), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Sekolah / Institusi'),
          'UI',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Periode'),
          '2024 - Sekarang',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Detail Pendidikan'),
          'Ilmu Komputer',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Tahun Mulai'),
          '2024',
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsNothing);
        expect(find.byType(EducationFormPage), findsNothing);

        // Kembali ke Home sebelum menguji form berikutnya
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 3. SkillFormPage
        await tester.ensureVisible(find.text('Skills'));
        await tester.tap(find.text('Skills'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tambah Keahlian').first);
        await tester.pumpAndSettle();
        expect(find.byType(SkillFormPage), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Keahlian'),
          'Flutter',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Level'),
          'Intermediate',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi Keahlian'),
          'Membangun UI lintas platform.',
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsNothing);
        expect(find.byType(SkillFormPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Verdict 2: SkillCard readability at 320x568 with 2.0x text scale', () {
    testWidgets(
      'SkillCard renders without overflow on 320x568 screen at textScale 2.0',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const skill = Skill(
          id: 'skill-1',
          title: 'Django & REST Framework',
          description: 'Merancang model relasional, serializer dengan validasi sanitasi, dan endpoint JSON untuk klien mobile.',
          level: 'Intermediate — Full-Stack Engineering',
          codeSnippet: 'class ProjectSerializer(serializers.ModelSerializer):',
        );

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: SkillCard(skill: skill),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Django & REST Framework'), findsOneWidget);
        expect(
          find.text('Intermediate — Full-Stack Engineering'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PortfolioDetailPage renders long badge and metadata cleanly at 320x568 with textScale 2.0',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const skill = Skill(
          id: 'skill-detail-1',
          title: 'Django & REST Framework',
          description: 'Merancang API untuk klien mobile.',
          level: 'Intermediate — Full-Stack Engineering',
        );

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            ),
            home: PortfolioDetailPage.skill(skill),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Intermediate — Full-Stack Engineering'),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group(
    'Verdict 3: SVG icon support in TechStackCard & PortfolioDetailPage',
    () {
      testWidgets(
        'valid SVG URL decodes as SvgPicture in card and detail page without falling back to error icon',
        (tester) async {
          const svgUrl = 'https://cdn.example.com/dart.svg';
          const validSvg =
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
              '<circle cx="12" cy="12" r="10" fill="#0175C2"/>'
              '</svg>';

          final previousOverrides = HttpOverrides.current;
          final fakeOverrides = _FakeHttpOverrides({
            svgUrl: (statusCode: HttpStatus.ok, bytes: utf8.encode(validSvg)),
          });
          HttpOverrides.global = fakeOverrides;
          addTearDown(() {
            HttpOverrides.global = previousOverrides;
          });

          const stack = TechStack(
            id: 1,
            name: 'Dart',
            iconUrl: svgUrl,
            filename: 'main.dart',
            codeSnippet: 'void main() {}',
            order: 1,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: TechStackCard(techStack: stack)),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(SvgPicture), findsOneWidget);
          expect(find.byIcon(Icons.code_rounded), findsNothing);
          expect(fakeOverrides.closedClientCount, greaterThanOrEqualTo(1));
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(
            MaterialApp(home: PortfolioDetailPage.techStack(stack)),
          );
          await tester.pumpAndSettle();

          expect(find.byType(SvgPicture), findsOneWidget);
          expect(find.byIcon(Icons.layers_rounded), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'invalid SVG HTTP response falls back to icon and data URI SVG decodes cleanly',
        (tester) async {
          const brokenUrl = 'https://cdn.example.com/broken.svg';
          const dataUriSvg =
              'data:image/svg+xml;utf8,'
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">'
              '<rect width="16" height="16" fill="#000"/>'
              '</svg>';

          final previousOverrides = HttpOverrides.current;
          final fakeOverrides = _FakeHttpOverrides({
            brokenUrl: (
              statusCode: HttpStatus.ok,
              bytes: utf8.encode('<html>not an svg</html>'),
            ),
          });
          HttpOverrides.global = fakeOverrides;
          addTearDown(() {
            HttpOverrides.global = previousOverrides;
          });

          const brokenStack = TechStack(
            id: 2,
            name: 'Broken',
            iconUrl: brokenUrl,
            filename: 'broken.dart',
            codeSnippet: 'void main() {}',
            order: 2,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: TechStackCard(techStack: brokenStack)),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.code_rounded), findsOneWidget);
          expect(fakeOverrides.closedClientCount, greaterThanOrEqualTo(1));
          expect(tester.takeException(), isNull);

          const dataStack = TechStack(
            id: 3,
            name: 'InlineSVG',
            iconUrl: dataUriSvg,
            filename: 'inline.dart',
            codeSnippet: 'void main() {}',
            order: 3,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: TechStackCard(techStack: dataStack)),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(SvgPicture), findsOneWidget);
          expect(find.byIcon(Icons.code_rounded), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    },
  );

  group(
    'Verdict 4: Release network permissions in Android & macOS configs',
    () {
      test('Android main manifest declares INTERNET, url_launcher queries, and macOS entitlements declare network.client', () {
        final androidManifest = File('android/app/src/main/AndroidManifest.xml')
            .readAsStringSync();
        expect(androidManifest, contains('android.permission.INTERNET'));
        expect(androidManifest, contains('android.intent.action.VIEW'));
        expect(androidManifest, contains('android:scheme="https"'));

        final macosRelease = File('macos/Runner/Release.entitlements')
            .readAsStringSync();
        expect(
          macosRelease,
          contains('<key>com.apple.security.network.client</key>'),
        );

        final macosDebugProfile = File('macos/Runner/DebugProfile.entitlements')
            .readAsStringSync();
        expect(
          macosDebugProfile,
          contains('<key>com.apple.security.network.client</key>'),
        );
      });
    },
  );

  group('Verdict 5: ProjectItemCard bounds image decode dimensions', () {
    testWidgets(
      'ProjectItemCard configures ResizeImage preserving aspect ratio at 312px width and TechStackCard uses ResizeImagePolicy.fit',
      (tester) async {
        tester.view.physicalSize = const Size(344, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const project = Project(
          id: 'proj-img',
          title: 'High Res Project',
          description: 'Menguji pembatasan ukuran dekode gambar.',
          category: 'Mobile Development',
          projectImageUrl: 'https://cdn.example.com/large-1600.png',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: ProjectItemCard(project: project),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final imageWidget = tester.widget<Image>(find.byType(Image));
        expect(imageWidget.image, isA<ResizeImage>());
        final resizeImage = imageWidget.image as ResizeImage;
        expect(resizeImage.width, 312);
        expect(resizeImage.height, isNull);

        const stack = TechStack(
          id: 9,
          name: 'Flutter',
          iconUrl: 'https://cdn.example.com/flutter.png',
          filename: 'main.dart',
          codeSnippet: 'void main() {}',
          order: 1,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: TechStackCard(techStack: stack)),
          ),
        );
        await tester.pump();

        final iconImage = tester.widget<Image>(find.byType(Image));
        expect(iconImage.image, isA<ResizeImage>());
        final iconResize = iconImage.image as ResizeImage;
        expect(iconResize.width, 40);
        expect(iconResize.height, 40);
        expect(iconResize.policy, ResizeImagePolicy.fit);
      },
    );
  });

  group('Follow-up Verdicts: Active tab FAB & clickable project URL', () {
    testWidgets(
      'Projects section FAB switches to Tambah Tech Stack on Tech Stack tab',
      (tester) async {
        await tester.pumpWidget(
          MyApp(apiClient: _createMockApiClient(), initialToken: 'test-token'),
        );
        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();

        // Tab awal (Projects): FAB menampilkan Tambah Proyek
        expect(
          find.descendant(
            of: find.byType(FloatingActionButton),
            matching: find.text('Tambah Proyek'),
          ),
          findsOneWidget,
        );

        // Pindah ke tab Tech Stack: FAB berubah menjadi Tambah Tech Stack
        await tester.tap(find.widgetWithText(Tab, 'Tech Stack'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FloatingActionButton),
            matching: find.text('Tambah Tech Stack'),
          ),
          findsOneWidget,
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.byType(TechStackFormPage), findsOneWidget);
      },
    );

    testWidgets(
      'tapping project URL in ProjectItemCard and PortfolioDetailPage launches external URL',
      (tester) async {
        final launchedUris = <Uri>[];
        debugUrlLauncherOverride = (uri) async {
          launchedUris.add(uri);
          return true;
        };
        addTearDown(() {
          debugUrlLauncherOverride = null;
        });

        const url = 'https://github.com/reshandytaftazani/myportofolio_mobile';
        const project = Project(
          id: 'proj-url',
          title: 'MyPortfolio Mobile',
          description: 'Aplikasi portofolio.',
          category: 'Mobile Development',
          projectUrl: url,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: ProjectItemCard(project: project)),
          ),
        );
        await tester.tap(find.text(url));
        await tester.pump();
        expect(launchedUris, [Uri.parse(url)]);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.project(project)),
        );
        await tester.tap(find.text(url));
        await tester.pump();
        expect(launchedUris.length, 2);
      },
    );
  });

  group('Regression: Category route resolution & drawer Back on dirty form', () {
    test('portfolioSectionFromRouteName parses valid, normalized, and invalid paths', () {
      expect(
        portfolioSectionFromRouteName('/section/projects'),
        PortfolioSection.projects,
      );
      expect(
        portfolioSectionFromRouteName('/section/experiences/'),
        PortfolioSection.experiences,
      );
      expect(
        portfolioSectionFromRouteName('/section/education?ref=direct'),
        PortfolioSection.education,
      );
      expect(
        portfolioSectionFromRouteName('/section/skills'),
        PortfolioSection.skills,
      );
      expect(portfolioSectionFromRouteName(null), isNull);
      expect(portfolioSectionFromRouteName(''), isNull);
      expect(portfolioSectionFromRouteName('/'), isNull);
      expect(portfolioSectionFromRouteName('/section'), isNull);
      expect(portfolioSectionFromRouteName('/section/unknown'), isNull);
    });

    for (final category in portfolioCategoryConfigs) {
      testWidgets(
        'direct link / refresh to ${category.routeName} restores section, Back returns Home, and Forward restores section',
        (tester) async {
          tester.platformDispatcher.defaultRouteNameTestValue =
              category.routeName;
          addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

          await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));
          await tester.pumpAndSettle();

          // Refresh / tautan langsung membuka halaman kategori yang sesuai
          final sectionPage = tester.widget<PortfolioSectionPage>(
            find.byType(PortfolioSectionPage),
          );
          expect(sectionPage.section, category.section);
          expect(find.text(category.name), findsWidgets);

          // Back mengembalikan ke Home
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(MyHomePage), findsOneWidget);
          expect(find.byType(PortfolioSectionPage), findsNothing);

          // Forward memulihkan kembali halaman kategori
          await tester.binding.handlePushRoute(category.routeName);
          await tester.pumpAndSettle();
          final restoredPage = tester.widget<PortfolioSectionPage>(
            find.byType(PortfolioSectionPage),
          );
          expect(restoredPage.section, category.section);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'unknown initial route falls back to MyHomePage cleanly without error',
      (tester) async {
        tester.platformDispatcher.defaultRouteNameTestValue =
            '/section/tidak-ada';
        addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

        await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));
        await tester.pumpAndSettle();

        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(PortfolioSectionPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'first Back closes open drawer on dirty form without discard dialog; second Back prompts and Buang exits form',
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

        // Isi draf sehingga form menjadi dirty
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'Draf Belum Disimpan',
        );
        await tester.pump();

        // Buka drawer
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsOneWidget);

        // Back pertama hanya menutup drawer tanpa dialog buang draf
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsNothing);
        expect(find.text('Buang Perubahan Draf?'), findsNothing);
        expect(find.byType(ProjectFormPage), findsOneWidget);
        expect(find.text('Draf Belum Disimpan'), findsOneWidget);

        // Back kedua (drawer sudah tertutup) menampilkan konfirmasi buang draf
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsOneWidget);

        // Pilih Batal -> form dan draf tetap terbuka
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);
        expect(find.text('Draf Belum Disimpan'), findsOneWidget);

        // Back lagi lalu pilih Buang -> benar-benar keluar dari form ke Projects
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Buang Perubahan Draf?'), findsOneWidget);
        await tester.tap(find.text('Buang'));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectFormPage), findsNothing);
        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
